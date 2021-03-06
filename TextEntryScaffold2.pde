import java.util.Arrays;
import java.util.Collections;
import java.util.Queue;
import java.util.LinkedList;
import java.util.ArrayList;

String[] phrases; //contains all of the phrases
int totalTrialNum = 4; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 445; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
                                      //http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';
int margin = 200;
ArrayList <String> currentMatches = new ArrayList<String>();
String[] dictionary;
String currentWord = "";
int lastSpace = 0;
Trie t;
int currentMatchLoc = 0;
int optIndex = 0;
PrintWriter output;
String results = "";

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases
    
  orientation(PORTRAIT); //can also be LANDSCAPE -- sets orientation on android device
  size(1080, 1920); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 36)); //set the font to arial 24
  //noStroke(); //my code doesn't use any strokes.
  t = new Trie();
  output = createWriter("outputs.txt");
  dictionary = loadStrings("dictionary.txt"); //load the dictionary set into memory
  for(int i = 0; i < dictionary.length; i++)
  {
    t.insert(dictionary[i]); 
  }
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(0); //clear background

 // image(watch,-200,200);
  fill(100);
  rect(200, 200, sizeOfInputArea, sizeOfInputArea); //input area should be 2" by 2"

  if (finishTime!=0)
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
    //finishTime = millis();
    //currTrialNum++;
    text(results, 300, 900);
    //if(currTrialNum == totalTrialNum-1) {
    //text("==================", 300, 900);
    //text("Trials complete!", 300, 940); //output
    //text("Total time taken: " + (finishTime - startTime),300,980); //output
    //text("Total letters entered: " + lettersEnteredTotal,300,1020); //output
    //text("Total letters expected: " + lettersExpectedTotal,300,1060); //output
    //text("Total errors entered: " + errorsTotal,300,1100); //output
    //text("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f),300,1140); //output
    //text("==================",300,1180);
    //}
    //output.flush();
    //output.close();
     //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(255);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped + "|", 70, 140); //draw what the user has entered thus far 
    fill(255, 0, 0);
    rect(350, 00, 150, 60); //drag next button
    fill(255);
    text("NEXT > ", 375, 40); //draw next label


    //my draw code
    //Hitboxes
    fill(128);
    //Top Key Hitboxes
    rect(margin, margin, sizeOfInputArea * 3 / 8, sizeOfInputArea / 3);
    rect(margin + sizeOfInputArea * 3 / 8, margin, sizeOfInputArea * 3 / 8, sizeOfInputArea/ 3);
    
    //Middle Key Hitboxes
    rect(margin, margin + sizeOfInputArea / 3, sizeOfInputArea * 3 / 8, sizeOfInputArea/ 3);
    rect(margin + sizeOfInputArea * 3 / 8, margin + sizeOfInputArea / 3, sizeOfInputArea * 3 / 8, sizeOfInputArea / 3);
    
    //Bottom Key Hitboxes
    rect(margin, margin + 2 * sizeOfInputArea / 3, sizeOfInputArea * 3 /8, sizeOfInputArea / 3);
    rect(margin + sizeOfInputArea * 3 / 8, margin + 2 * sizeOfInputArea / 3, sizeOfInputArea * 3 / 8, sizeOfInputArea / 3);

    //next word key hitbox
    rect(margin + 2 * sizeOfInputArea * 3 / 8, margin, sizeOfInputArea / 4, sizeOfInputArea / 3);
    
    //space key hitbox
    rect(margin + 2 * sizeOfInputArea * 3 / 8, margin + sizeOfInputArea / 3, sizeOfInputArea / 4, sizeOfInputArea / 3);
    
    //Delete key hitbox
    rect(margin + 2 * sizeOfInputArea * 3 / 8, margin + 2 * sizeOfInputArea / 3, sizeOfInputArea / 4, sizeOfInputArea / 3);
    
    
    //Overlays
    fill(255);
    //Top keys
    rect(margin + 3, margin + 3, sizeOfInputArea * 3 / 8 - 6, sizeOfInputArea / 3 - 6, 7);
    rect(margin + sizeOfInputArea * 3 / 8 + 3, margin + 3, sizeOfInputArea * 3 / 8 - 6, sizeOfInputArea / 3 - 6, 7);
    //middle
    rect(margin + 3, margin + sizeOfInputArea / 3 + 3, sizeOfInputArea * 3 / 8 - 6, sizeOfInputArea / 3 - 6, 7);
    rect(margin + sizeOfInputArea * 3 / 8 + 3, margin + sizeOfInputArea / 3 + 3, sizeOfInputArea * 3 / 8 - 6, sizeOfInputArea / 3 - 6, 7);
    //bottom
    rect(margin + 3, margin + 2 * sizeOfInputArea / 3 + 3, sizeOfInputArea * 3 /8 - 6, sizeOfInputArea / 3 - 6, 7);
    rect(margin + sizeOfInputArea * 3 / 8 + 3, margin + 2 * sizeOfInputArea / 3 + 3, sizeOfInputArea * 3 / 8 - 6, sizeOfInputArea / 3 - 6, 7);
    //next word
    rect(margin + 2 * sizeOfInputArea * 3 / 8 + 3, margin + 3, sizeOfInputArea / 4 - 6, sizeOfInputArea / 3 - 6, 7);
    //space
    rect(margin + 2 * sizeOfInputArea * 3 / 8 + 3, margin + sizeOfInputArea / 3 + 3, sizeOfInputArea / 4 - 6, sizeOfInputArea / 3 - 6, 7);
    //delete
    rect(margin + 2 * sizeOfInputArea * 3 / 8 + 3, margin + 2 * sizeOfInputArea / 3 + 3, sizeOfInputArea / 4 - 6, sizeOfInputArea / 3 - 6, 7);
    
    
    //letters
    //Dont try to understand this
    fill(64);
    textAlign(CENTER);
    text("QWERT", margin + sizeOfInputArea * 3 / 8 / 2, margin + sizeOfInputArea * 1 / 5);
    text("YUIOP", margin + sizeOfInputArea * 3 / 8 + sizeOfInputArea * 3 / 8 / 2, margin + sizeOfInputArea * 1 / 5);
    text("ASDF", margin + sizeOfInputArea * 3 / 8 / 2, margin + sizeOfInputArea / 3 + sizeOfInputArea * 1 / 5);
    text("GHJKL", margin + sizeOfInputArea * 3 / 8 + sizeOfInputArea * 3 / 8 / 2, margin + sizeOfInputArea / 3 + sizeOfInputArea * 1 / 5);
    text("ZXCV", margin + sizeOfInputArea * 3 / 8 / 2, margin + 2 * sizeOfInputArea / 3 + sizeOfInputArea * 1 / 5);
    text("BNM", margin + sizeOfInputArea * 3 / 8 + sizeOfInputArea * 3 / 8 / 2, margin + 2 * sizeOfInputArea / 3 + sizeOfInputArea * 1 / 5);
    text("->", margin + 2 * sizeOfInputArea * 3 / 8 + sizeOfInputArea / 4 / 2, margin + sizeOfInputArea * 1 / 5);
    text("_", margin + 2 * sizeOfInputArea * 3 / 8 + sizeOfInputArea / 4 / 2, margin + sizeOfInputArea / 3 + sizeOfInputArea * 1 / 5); 
    text("<", margin + 2 * sizeOfInputArea * 3 / 8 + sizeOfInputArea / 4 / 2, margin + 2 * sizeOfInputArea / 3 + sizeOfInputArea * 1 / 5);    
  }
  
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}
//***************************************************************
//Put all algorithm stuff that should happen on click in here!!!
//input string variable is called currentTyped
//***************************************************************
void mousePressed()
{
  boolean addLetter = false;
  if(didMouseClick(margin, margin, sizeOfInputArea * 3 / 8, sizeOfInputArea / 3)) {
   /*
   PUT FUNCTIONALITY FOR qwert HERE!
   */
   currentWord += '2';
        
   addLetter = true;
  }
  if(didMouseClick(margin + sizeOfInputArea * 3 / 8, margin, sizeOfInputArea * 3 / 8, sizeOfInputArea/ 3)) {
   /*
   PUT FUNCTIONALITY FOR yuiop HERE!
   */
   currentWord += '3';
        
   addLetter = true;
  }
  if(didMouseClick(margin, margin + sizeOfInputArea / 3, sizeOfInputArea * 3 / 8, sizeOfInputArea/ 3)) {
   /*
   PUT FUNCTIONALITY FOR asdf HERE!
   */
   currentWord += '4';
        
   addLetter = true;
  }
  if(didMouseClick(margin + sizeOfInputArea * 3 / 8, margin + sizeOfInputArea / 3, sizeOfInputArea * 3 / 8, sizeOfInputArea / 3)) {
   /*
   PUT FUNCTIONALITY FOR ghjkl HERE
   */
   currentWord += '5';
        
   addLetter = true;
  }
  if(didMouseClick(margin, margin + 2 * sizeOfInputArea / 3, sizeOfInputArea * 3 /8, sizeOfInputArea / 3)) {
   /*
   PUT FUNCTIONALITY FOR zxcv HERE
   */
   currentWord += '6';
        
   addLetter = true;
  }
  if(didMouseClick(margin + sizeOfInputArea * 3 / 8, margin + 2 * sizeOfInputArea / 3, sizeOfInputArea * 3 / 8, sizeOfInputArea / 3)) {
   /*
   PUT FUNCTIONALITY FOR bnm HERE
   */
    currentWord += '7';
        
    addLetter = true;
  }
  //Next word 
  if(didMouseClick(margin + 2 * sizeOfInputArea * 3 / 8, margin, sizeOfInputArea / 4, sizeOfInputArea / 3)) {
     currentMatchLoc++;
     addLetter = true;
  }
  //space bar
  if(didMouseClick(margin + 2 * sizeOfInputArea * 3 / 8, margin + sizeOfInputArea / 3, sizeOfInputArea / 4, sizeOfInputArea / 3)) {
     currentTyped += ' '; 
     currentWord = "";
     lastSpace = currentTyped.length() - 1;
     currentMatchLoc = 0;
  }
  //Delete key
  if(didMouseClick(margin + 2 * sizeOfInputArea * 3 / 8, margin + 2 * sizeOfInputArea / 3, sizeOfInputArea / 4, sizeOfInputArea / 3)) {
     if(currentTyped.length() > 0) {
         currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
         boolean foundSpace = false;
         for(int j = currentTyped.length()-1; j >= 0; j--)
          {
            if(currentTyped.charAt(j) == ' ')
            {
              lastSpace = j;
              foundSpace = true;
              break; 
            }
          }
          if(!foundSpace)
          {
            lastSpace = 0;
            currentWord = currentTyped.substring(0,currentTyped.length());
          }
          else
          {
            currentWord = currentTyped.substring(lastSpace+1,currentTyped.length());
          }
          currentWord = convertLetterstoNumbers(currentWord);
          currentMatchLoc = 0;
     }
     else
        {
          currentTyped = "";
          currentWord = "";
          lastSpace = 0;
          currentMatchLoc = 0;
        }
  }
  if(addLetter)
      {
        System.out.println(lastSpace);
        if(lastSpace > 0)
        {
          currentTyped = currentTyped.substring(0, lastSpace+1);
          System.out.println("****"+currentTyped+"****     ****"+currentWord+"****");
        }
        else
        {
          currentTyped = "";
        }
        currentMatches = checkWord(currentWord);
        //currentMatchLoc = 0;
        currentTyped += currentMatches.get(currentMatchLoc % currentMatches.size());
      }
  //You are allowed to have a next button outside the 2" area
  if (didMouseClick(350, 00, 150, 60)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
  
  
}

//THIS IS THE AUTOCOMPLETE STUFF
ArrayList <String> checkWord(String currentWord)
{
  currentWord = currentWord.trim();
  ArrayList <String> word = t.bfs_search(currentWord);
  if(word != null && word.size() > 0)
  {
    return word;
  }
  else
  {
    
    for(int i = currentWord.length(); i >=0 ; i--)
    {
      word = t.bfs_search(currentWord.substring(0,i));
      if(word != null && word.size() > 0)
      {
        System.out.println(word.get(0));
        for(int j = i; j < currentWord.length(); j++)
        {
          for(int k = 0; k < word.size(); k++)
          {
            int loc = currentWord.length()-j-1;
            word.set(k, word.get(k)+ getCharbyNum(currentWord.charAt(currentWord.length()-loc-1)));
          }
        }
        return word;
      }
    }
    
    word.add("");
    for(int j = 0; j < currentWord.length(); j++)
    {
      word.set(0, word.get(0) + getCharbyNum(currentWord.charAt(currentWord.length()-j-1)));
    }
    return word;
  }
}

String convertLetterstoNumbers(String word)
{
  String val = "";
  System.out.println(word);
  for(int i = 0; i < word.length(); i++)
  {
    System.out.println(word.charAt(i)+"    "+convertCharacterToNum(word.charAt(i)));
    val += convertCharacterToNum(word.charAt(i));
  }
  return val; 
}

char convertCharacterToNum(char letter)
{
  switch(letter)
  {
    case 'q':
    case 'w':
    case 'e':
    case 'r':
    case 't':
      return '2';
    case 'y':
    case 'u':
    case 'i':
    case 'o':
    case 'p':
      return '3';
    case 'a':
    case 's':
    case 'd':
    case 'f':
      return '4';
    case 'g':
    case 'h':
    case 'j':
    case 'k':
    case 'l':
      return '5';
    case 'z':
    case 'x':
    case 'c':
    case 'v':
      return '6';
    case 'b':
    case 'n':
    case 'm':
      return '7';
  }
  return ' ';
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

    if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    output.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    output.println("Target phrase: " + currentPhrase); //output
    output.println("Phrase length: " + currentPhrase.length()); //output
    output.println("User typed: " + currentTyped); //output
    output.println("User typed length: " + currentTyped.length()); //output
    output.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    output.println("Time taken on this trial: " + (millis()-lastTime)); //output
    output.println("Time taken since beginning: " + (millis()-startTime)); //output
    output.println("==================");
    lettersExpectedTotal+=currentPhrase.length();
    lettersEnteredTotal+=currentTyped.length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    results += "================== \n Trials complete! \n" + "Total time taken: " + (finishTime - startTime) + "\n Total letters entered: " + lettersEnteredTotal
    + "\n Total errors entered: " + errorsTotal + "\n WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f)
    + "\n ==================";
    output.print("==================");
    output.println("Trials complete!"); //output
    output.println("Total time taken: " + (finishTime - startTime)); //output
    output.println("Total letters entered: " + lettersEnteredTotal); //output
    output.println("Total letters expected: " + lettersExpectedTotal); //output
    output.println("Total errors entered: " + errorsTotal); //output
    output.println("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f)); //output
    output.println("==================");
    output.flush();
    output.close();
    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  }
  else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentWord = "";
  lastSpace = 0;
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

char getCharbyNum(char num)
{
  switch(num)
  {
    case '2':
      return 'e';
    case '3':
      return 'i';
    case '4':
      return 'a';
    case '5':
      return 'g';
    case '6':
      return 'c';
    case '7':
      return 'b';
  }
  return ' ';
}

public class Trie {
  
  private final int R = 26;  // the trie branches 
  private Node root = new Node(); // the root node
  
  // the t9 mapped array which maps number to string on the typing board
  private String[] t9 = {"", "", "qwert", "yuiop", "asdf", "ghjkl", "zxcv", "bnm"};
  
  // trie node definition
  private class Node {
    private boolean isWord;
    private Node[] next;
    
    public Node() {
      this(false);
    }
    
    public Node(boolean isWord) {
      this.isWord = isWord;
      this.next = new Node[R];
    }
  }
  
  // insert a word to the trie
  public void insert(String s) {
    Node current = root;
    
    for(int i = 0; i < s.length(); i++) {
      if(current.next[s.charAt(i) - 'a'] == null) {
        Node n = new Node();
        current.next[s.charAt(i) - 'a'] = n;
      } 
      
      current = current.next[s.charAt(i) - 'a'];
    }
    
    current.isWord = true;
  }
  
  // insert a character to some node
  public void insert(Node current, char c) {
    if(current.next[c - 'a'] == null) {
      Node node = new Node();
      current.next[c - 'a'] = node;
    }
    current = current.next[c - 'a'];
  }
  
  // search a word in the trie
  public boolean search(String s) {
    Node current = root;
    
    for(int i = 0; i < s.length(); i++) {
      if(current.next[s.charAt(i) - 'a'] == null) {
        return false;
      } 
      current = current.next[s.charAt(i) - 'a'];
    }
    
    return current.isWord == true;
  }
  
  // search a word in the trie
  public boolean searchForPartial(String s) {
    Node current = root;
    
    for(int i = 0; i < s.length(); i++) {
      if(current.next[s.charAt(i) - 'a'] == null) {
        return false;
      } 
      current = current.next[s.charAt(i) - 'a'];
    }
    
    return true;
  }
  
  // breadth first search for a number string use queue
  public ArrayList <String> bfs_search(String strNum) {
    Queue<String> q = new LinkedList<String>();
    ArrayList <String> matches = new ArrayList <String> ();
    
    q.add("");
    
    for(int i = 0; i < strNum.length(); i++) {
      String keyStr = t9[strNum.charAt(i) - '0'];
      int len = q.size();
      
      while(len -- > 0) {
        String preStr = q.remove();
        for(int j = 0; j < keyStr.length(); j++) {
          String tmpStr = preStr + keyStr.charAt(j);
          //q.add(tmpStr);
          if(tmpStr.length() == strNum.length() && search(tmpStr)) {
            matches.add(tmpStr);
          } else {
            if(searchForPartial(tmpStr))
            {
              q.add(tmpStr);
            }
          }
        }
      }
    }
    return matches;
  }
  
  // delete a node
  public void delete(Node node) {
    for(int i = 0; i < R; i++) {
      if(node.next != null) {
        delete(node.next[i]);
      }
    }
    node = null;
  }
  
  // print words
  public void print(Node node) {
    if(node == null) return;
    for(int i = 0; i < R; i++) {
      if(node.next[i] != null) {
        System.out.print((char) (97 + i));
        if(node.next[i].isWord == true) {
          System.out.println();
        }
        print(node.next[i]);
      }
      
    }
  }
  
  // print words from root
  public void print() {
    print(root);
  }
  
  // convert number string to String array
  private String[] numToString(String strNum) {
    String[] strArray = new String[strNum.length()];
    for(int i = 0; i < strNum.length(); i++) {
      strArray[i] = t9[strNum.charAt(i) - '0'];
    }
    return strArray;
  }
}



//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}