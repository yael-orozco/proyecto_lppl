%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"
#include "libtds.h"

#define  retornar(x) {if (verbosidad) ECHO ; return (x) ; }
%}
/*-----------------------------------------------------------------------------
  Estas opciones evitan "warnings" innecesarios y permiten obtener el
  numero de linea actual en la variable global "yylineno".
-----------------------------------------------------------------------------*/
%option noinput       
%option nounput       
%option yylineno  

delimitador    [ \t]+
comentario     \/\/.*\n
letra          [a-zA-Z]
digito         [0-9]
identificador  {letra}({letra}|{digito}|_)*
constante      (\.{digito}+|{digito}+\.{digito}*|{digito}+)

%%

{delimitador}   {if (verbosidad) ECHO;      }
{comentario}    {if (verbosidad) {ECHO; printf("%d.-  ", yylineno);}}
"\n"            {if (verbosidad) { ECHO; printf("%d.-  ", yylineno);}}
"+"             { retornar (MAS_);          }
"-"             { retornar (MENOS_);        }
"*"             { retornar (POR_);          }
"/"             { retornar (DIV_);          }
"%"             { retornar (MOD_);          }
"="             { retornar (IGUAL_);        }
"("             { retornar (APAR_);         }
")"             { retornar (CPAR_);         }
"{"             { retornar (ALLAVE_);       }
"}"             { retornar (CLLAVE_);       }
"["             { retornar (ACOR_);         }
"]"             { retornar (CCOR_);         }
","             { retornar (COMA_);         }
"."             { retornar (PTO_);          }
";"             { retornar (PTOCOMA_);      }

"=="            { retornar (COMPIG_);       }
"!="            { retornar (COMPDIST_);     }
">"             { retornar (COMPMAY_);      }
"<"             { retornar (COMPMEN_);      }
">="            { retornar (COMPMAYIG_);    }
"<="            { retornar (COMPMENIG_);    }
"&&"            { retornar (OPAND_);        }
"||"            { retornar (OPOR_);         }
"++"            { retornar (OPINCRE_);      }
"--"            { retornar (OPDECRE_);      }
"+="            { retornar (MASIG_);        }
"-="            { retornar (MENOSIG_);      }
"*="            { retornar (PORIG_);        }
"!"             { retornar (OPNOT_);        }

"read"          { retornar (READ_);         }
"struct"        { retornar (STRUCT_);       }
"print"         { retornar (PRINT_);        }
"return"        { retornar (RETURN_);       }
"if"            { retornar (IF_);           }
"else"          { retornar (ELSE_);         }
"elseif"        { retornar (ELSEIF_);       }
"while"         { retornar (WHILE_);        }
"do"            { retornar (DO_);           }
"int"           { retornar (INT_);          }
"bool"          { retornar (BOOL_);         }
"true"          { retornar (TRUE_);         }
"false"         { retornar (FALSE_);        }

{constante}     { yylval.cent = atoi(yytext); retornar(CTE_); }
{identificador} { yylval.ident = strdup(yytext); retornar(ID_); }

.		{ yyerror("Caracter desconocido") ;}


%%
