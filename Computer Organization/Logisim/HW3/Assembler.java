/* 
* Title: Assembler.java
* Authors: Calvin Spencer and Chase Coley
* Computer Organization (CSC 250) with Dr. Locke
*
* This program prompts the user to select an input file with assembly code, 
* then translates the selected file into machine code, which is output in a 
* new file named by the user. This output file is formatted to be loaded into
* logisim RAM.
*/

import javax.swing.*;
import java.io.*;
import java.util.*;


class Assembler{
    public static void main(String[] args){
        //Get working directory
        String wd = System.getProperty("user.dir");

        //Construct new JFileChooser in working directory
        JFileChooser inChooser = new JFileChooser(wd); 

        JFrame assemblerFrame = new JFrame("Select the file containing assembler code");

        //Open JFileChooser using a standard JFrame
        inChooser.showOpenDialog(assemblerFrame);

        //Store the user-selected input file with assembly code
        File inFile = inChooser.getSelectedFile();

        ArrayList<String> assemblyCode = readFile(inFile);
        ArrayList<String> hexCode = new ArrayList<String>();

        //Populate hexCode with translations from assemblyCode
        for (String code: assemblyCode){
            hexCode.add(translate(code));
        }

        //Get file name for the output file
        String fileName = JOptionPane.showInputDialog("Assembly instructions successfully translated!\nPlease enter your desired filename for the .txt", "filename");

        //Construct output file
        File outFile  = new File(fileName + ".txt");

        
        try{
            //Construct file writers
            FileWriter fWriter = new FileWriter(outFile);
            BufferedWriter bWriter = new BufferedWriter(fWriter);

            //Initialize file
            bWriter.write("v2.0 raw");

             //Load hex codes into new file
            for (String hex: hexCode){
                bWriter.newLine();
                bWriter.write(hex);
            }
            //Close Buffered Writer
            bWriter.close();
        }
        catch (IOException e){
            System.out.println("IO Error. Try a different file name?");
            System.exit(0);
        }
        
        System.out.println("File " + fileName + " written successfully");
        System.exit(0);
    }


    /* readFile: parses the input file into an arraylist with each element containing a string
    * @param file: input file with assembly code
    * @return arraylist of type string, each element filled with a line from the input file
    */
    public static ArrayList<String> readFile(File file){
        ArrayList<String> fileContents = new ArrayList<String>();

        try{
            //Scanner to read file;
            Scanner scanner = new Scanner(file);
            //Repeat for each line in the file
            while (scanner.hasNextLine()){
                String nextLine = scanner.nextLine();
                fileContents.add(nextLine);
            }
            //Close scanner
            scanner.close();
        }
        catch (IOException e){
            System.out.println("File IO Error: " + e);
            System.exit(0);
        }
        return fileContents;
    }

    /* translate: converts each assembler instruction to machine code
    * @param instruction: assembler instruction from file ArrayList
    * @return String (2 bit hex) of state that assembler instruction corresponds to
    * @throws exception if an instruction is invalid
    */
    public static String translate(String str){
        String machineCode = "-1";
        String instruction = str;

        //Remove spaces
        instruction = instruction.replaceAll(" ", "");

        //Convert to lower case
        instruction = instruction.toLowerCase();

        //Edge cases where the string contains a parameter in addition to the instruction
        if (instruction.contains("jmp")){
            //Adds a '\n' after the hex state so that the parameter ends up on the line following the hex state 
            machineCode = "0A\n" + instruction.replaceAll("jmp", "");
        }
        else if (instruction.contains("load")){
            machineCode = "0E\n" + instruction.replaceAll("load", "");
        }
        
        //Switch depending on all lower case instruction String
        switch (instruction){
            case "": machineCode = "00";
                break;
            case "main": machineCode = "00";
                break;
            case "input": machineCode = "04";
                break;
            case "output": machineCode = "07";
                break;
            case "inc": machineCode = "14";
                break;
            case "mov": machineCode = "17";
                break;
            case "add": machineCode = "1A";
                break;
            case "halt": machineCode = "1D";
                break;
        }
        
        //If the instruction did not match any codes
        if (machineCode.equals("-1")){
            System.out.println("Error! Double-check your assembler instructions.");
            System.exit(0);
        }

        return machineCode;
    }
}
