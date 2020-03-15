/* Cursaru Razvan-Mihai 331CC */

/* Start - Flex Dependencies and options */
%option noyywrap
%option nounput
%option noinput
%option stack
/* Start - Flex Dependencies and options */

/* Start - C Dependencies, functions and variables */
%{
    // The depth level at a specific moment of runtime
    int currentDepth = 0;

    // A simple function that prints the needed prefix indentation
    void PrintIndent()
    {
      for (int i=0; i<currentDepth; i++)
      {
        printf("| ");
      }
    }
%}
/* End - C Dependencies, functions and variables */

/* Start - Regex mania <3 */
document            ---
comment             #.*

keyTrailingColon    ": "

numericValue        [-+]?[0-9]*\.?[0-9]+
stringValue         [-_a-zA-Z]+[-_A-Za-z0-9]*

quote               '
anythingButQuote    [^']            

startingList        \[
endingList          \]

startingBracket     \{
endingBracket       \}

other               .|\n
/* End - Regex mania <3 */

/* Start - States used in the parsing process */
%s STARTING_QUOTE_STATE KEY_STATE STARTING_LIST_STATE STARTING_BRACKET_STATE
/* End - States used in the parsing process */

/* Start - Pattern matching code */
%%
{document} {
	printf("| document:\n");
  printf("| | map value\n");

  // Start with depth level 2 at the beginning of document
  currentDepth = 2;
}
{comment}	{
  // skip comments
}

{stringValue}/{keyTrailingColon} {
  // increase depth level and push key state

  currentDepth++;
  PrintIndent();
  printf("key: [%s]\n", yytext);

  yy_push_state(KEY_STATE);
}

<KEY_STATE,STARTING_LIST_STATE>{quote} {
  // push first quote state for strings if key state is current

  PrintIndent();
  printf("string value: [");

  yy_push_state(STARTING_QUOTE_STATE);
}

<KEY_STATE>{numericValue} {
  // print numeric value, decrease depth level and pop key state if key state is current

  PrintIndent();
  printf("numeric value: [%s]\n", yytext);

  currentDepth--;
  yy_pop_state();
}

<KEY_STATE>{stringValue} {
  // print string value, decrease depth level and pop key state if key state is current

  PrintIndent();
  printf("string value: [%s]\n", yytext);

  currentDepth--;
  yy_pop_state();
}

<KEY_STATE>{startingBracket} {
  // pop key state and push bracket start state if key state is current

  PrintIndent();
  printf("map value\n");

  yy_pop_state();
  yy_push_state(STARTING_BRACKET_STATE);
}

<STARTING_LIST_STATE>{startingBracket} {
  // push bracket start state if start list state is current
  
  PrintIndent();
  printf("map value\n");

  yy_push_state(STARTING_BRACKET_STATE);
}

<KEY_STATE,STARTING_LIST_STATE>{startingList} {
  // push list start state if key or start list state is current

  PrintIndent();
  printf("list value\n");

  currentDepth++;
  yy_push_state(STARTING_LIST_STATE);
}

<STARTING_LIST_STATE>{numericValue} {
  // print numeric value if list start state is current, without popping the last state

  PrintIndent();
  printf("numeric value: [%s]\n", yytext);
}

<STARTING_LIST_STATE>{stringValue} {
  // print string value if list start state is current, without popping the last state

  PrintIndent();
  printf("string value: [%s]\n", yytext);
}

<STARTING_LIST_STATE>{endingList} {
  // decrease depth level, if the immediate element below current state is key state and pop the list start state 

  if(yy_top_state() == KEY_STATE) currentDepth--;
  yy_pop_state();
 
  currentDepth--;
}

<STARTING_BRACKET_STATE>{endingBracket} {
  // decrease depth level if the immediate element below current state is list start state and pop the bracket start state

  if(yy_top_state() != STARTING_LIST_STATE) currentDepth--;
  yy_pop_state();
}

<STARTING_QUOTE_STATE>{anythingButQuote} {
  printf("%s", yytext);
}
<STARTING_QUOTE_STATE>{quote}	{
  // print quote termination and decrease depth level if the immediate element below current state is key state and pop the quote state
  
  printf("]\n");
  
  if(yy_top_state() == KEY_STATE)
  {
    currentDepth--;
    yy_pop_state();
  }

  yy_pop_state();
}

{other} {
  // skip anything else, including \n
}

%%
/* End - Pattern matching code */

/* Start - Main code */
int main(int argc, char** argv)
{
  // open the file at the path received as first argument
  yyin = fopen(argv[1], "r");
  // start the lexing process
  yylex();
  // end gracefully
  return 0;
}
/* End - Main code */