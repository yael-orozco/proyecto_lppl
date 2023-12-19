/*****************************************************************************/
/*****************************************************************************/
#ifndef _HEADER_H
#define _HEADER_H

/****************************************************** Constantes generales */
#define TRUE  1
#define FALSE 0
#define TALLA_TIPO_SIMPLE 1   /*Talla asociada tipos simples*/
#define TALLA_SEGENLACES 2    /*Talla del segmento de enlaces de control*/
/************************************* Variables externas definidas en el AL */
extern int yylex();
extern int yyparse();

extern int verTdS;      /*Flag para saber si mostrar TdS*/


extern FILE *yyin;
extern int   yylineno;
extern char *yytext;                         /* Patron detectado             */
/********* Funciones y variables externas definidas en el Programa Principal */
extern void yyerror(const char * msg) ;      /* Tratamiento de errores       */

extern int verbosidad;                   /* Flag si se desea una traza       */
extern int numErrores;                   /* Contador del numero de errores   */
extern int verTdS;

struct PARAM{
    int refe;
    int talla;
};

struct STRUCT_MENOSC{
    int refe;
    int talla;
};

struct EXPRE{
    int t;
};

#endif  /* _HEADER_H */
/*****************************************************************************/
/*****************************************************************************/
