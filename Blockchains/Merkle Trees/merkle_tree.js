export class MerkleTree {
	constructor(levels, hasher) {
		this.levels = levels;
		this.hasher = hasher;

		// node -> index at level 0
		this.nodeMap = {};

		// [level, index] -> node
		this.positionMap = {};

		this.nextAppendIndex = 0;
		this.increment = 0;

		this.levelZeros = this.loadLevelZeros(this.levels);

		// Here is how a zero should look like: 0n 
		// This is 0 in BigInt format
		// Start with bottom row as 0, when append update leaf and sibling hashes
		// Dont store the tree in memory, 
		// Odd is right, Even is left
		// Everything you havent calculated before should be 0 or hash of 0,0
		
	}

	append(element) {
		this.nodeMap[element] = this.nextAppendIndex;

		this.positionMap[[this.levels, this.nextAppendIndex]] = element;

		this.nextAppendIndex++;
	}

	appendAll(elements) {
		for(let element of elements) {
			this.append(element);
		}
	}

	getBottomIndex(element) {
		return this.nodeMap[element];
	}

	getNode(level, index) {
		// Look at the position map
		let foundNode = this.positionMap[[level, index]];

		// If index is beyond the last element at the level -> return the "zero" at that level
		if (index >= this.nextAppendIndex && level == this.levels){
			return 0n;
		}
		// positionMap lookupfailed, calculate the element, update the map
		else if (typeof foundNode === 'undefined'){
			let leftChild = this.getNode(level+1, 2*index);
			let rightChild = this.getNode(level+1, (2*index)+1);

			if (leftChild == this.levelZeros[level] && rightChild == this.levelZeros[level]){
				// Calculate the element
				let element = this.levelZeros[level-1];
				return element;
			} else {
				// Calculate the element
				let element = this.hasher(leftChild, rightChild);

				// Update the map
				this.positionMap[[level, index]] = element;
				return element;
			}
		}
		// positionMap lookup was a success (foundNode != undefined)
		else {
			return foundNode;
		}
	}

	getRoot() {
		return this.getNode(0, 0);
	}

	// Load zerosArray[] with zeros for each level
	loadLevelZeros(levels){
		let zerosArray = [0n];
		for (let i = 1; i < levels; i++){
			zerosArray.push(this.hasher(zerosArray[i-1], zerosArray[i-1]));
		}
		return zerosArray.reverse();
	}

	// Find [[level, index]] node in positionMap
	// If undefined, return the zero for that level
	getFromPositionMap(level, index){
		let result = this.positionMap[[level, index]];
		if (typeof result === "undefined"){
			return this.levelZeros[level-1];
		}
		else {
			return result;
		}
	}

	getProof(bottomIndex) {
		// Initialize lists
		let siblings = [];
		let isLeft = [];

		// Call getRoot() to lazily evaluate all elements in the positionMap
		let root = this.getRoot();

		// Start from bottomLevel at bottomIndex, and backward-calculate siblings and isLeft
		var currentLevelIndex = bottomIndex;

		// Move up the tree (leaves -> root)
		for (let level = this.levels; level > 0; level--){
			// Odd is right, even is left
			let left = currentLevelIndex % 2 == 0;
			isLeft.push(left);
			
			// Get node to the right
			if (left){
				siblings.push(this.getFromPositionMap(level, currentLevelIndex + 1));
			}
			// Get node to the left 
			else {
				siblings.push(this.getFromPositionMap(level, currentLevelIndex - 1));
			}

			// Index of upper level = currentLevelIndex / 2
			currentLevelIndex = Math.floor(currentLevelIndex/2);
		}
		// Reversing lists to match output.txt
		return [root, siblings.reverse(), isLeft.reverse()];
	}
}




