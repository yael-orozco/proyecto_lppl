%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "libtds.h"

int funcionMain=FALSE;
int tmpdvar=-1;
%}

%token  APAR_  CPAR_  MAS_  MENOS_  POR_  DIV_  MOD_  IGUAL_ ALLAVE_  CLLAVE_  ACOR_  CCOR_  COMA_  PTO_ PTOCOMA_
%token  COMPIG_  COMPDIST_  COMPMAY_ COMPMAYIG_  COMPMEN_ COMPMENIG_
%token  OPAND_  OPOR_  OPINCRE_  OPDECRE_  OPNOT_  MASIG_  MENOSIG_  PORIG_
%token  READ_  STRUCT_  PRINT_  RETURN_
%token  IF_  ELSE_  ELSEIF_  WHILE_  DO_  
%token  INT_  BOOL_  
%token  TRUE_  FALSE_

%token<ident> ID_
%token<cent> CTE_    

%union {
       char *ident;
       int cent;
       int t;
       struct PARAM r;
       struct STRUCT_MENOSC s;
       struct EXPRE e;
       int u;
}

%type<t> tipoSimple INT_ BOOL_ 
%type<r> paramForm listaParamForm paramAct listaParamAct
%type<s> listaCampos
%type<e> expre expreLogic expreIgual expreRel expreAd expreMul expreUna expreSufi const TRUE_ FALSE_
%type<u> opUna;

%%

programa 
       : 
       {
              dvar = 0;
              niv = 0;
              cargaContexto(niv);
       }
       listaDeclaraciones{
              if(funcionMain == FALSE){
                     yyerror("No hay funcion main");
              }
              if(funcionMain > 1){
                     yyerror("Mas de una funcion main");
              }
              descargaContexto(niv);
       }
       ;
listaDeclaraciones
       : declaracion
       | listaDeclaraciones declaracion
       ;
declaracion
       : declaracionVar
       | declaracionFunc
       ;
declaracionVar
       : tipoSimple ID_ PTOCOMA_ {
              if(!insTdS($2, VARIABLE, $1, niv, dvar, -1)){
                     yyerror("Identificador repetido");
              }
              else{
                     dvar += TALLA_TIPO_SIMPLE;   
              }       
       }
       | tipoSimple ID_ ACOR_ CTE_ CCOR_ PTOCOMA_ {
              int numelem = $4;
              if ( $4 <= 0) {
                     yyerror("Talla inapropiada del array");
                     numelem = 0;
              }
              int refe = insTdA( $1, numelem);
              if ( !insTdS( $2, VARIABLE, T_ARRAY, niv, dvar, refe) )
                     yyerror ("Identificador repetido");
              else dvar += numelem * TALLA_TIPO_SIMPLE;
       }
       | STRUCT_ ALLAVE_ listaCampos CLLAVE_ ID_ PTOCOMA_{
              if(!insTdS($5, VARIABLE, T_RECORD, niv, dvar, $3.refe)){
                     yyerror("identificador estructura repetido");
              }
              else{
                     dvar += $3.talla;
              }
       }
       ;
tipoSimple
       : INT_ { $$ = T_ENTERO; }
       | BOOL_ { $$ = T_LOGICO; }
       ;
listaCampos
       : tipoSimple ID_ PTOCOMA_{
              int refe = insTdR(-1, $2, $1, 0);
              if(refe != -1){
                     $$.talla = TALLA_TIPO_SIMPLE;
              }
              $$.refe = refe;
       }
       | listaCampos tipoSimple ID_ PTOCOMA_{
              int refe = insTdR($1.refe, $3, $2, $1.talla);
              if(refe != -1){
                     $$.refe = refe;
                     $$.talla = $1.talla + TALLA_TIPO_SIMPLE;
              }
              else{
                     yyerror("Nombre de campo repetido");
              }
       }
       ;
declaracionFunc
       : tipoSimple ID_ 
       {      
              if(strcmp($2, "main") == 0){
                     funcionMain = TRUE;
              }
              niv++;
              cargaContexto(niv);
              $<cent>$ = dvar;
              dvar = 0;
       }
       APAR_ paramForm CPAR_ 
       {
              int refe = $5.refe;
              if(!insTdS($2, FUNCION, $1, niv-1, -1, refe)){
                     yyerror("identificador de funcion repetido");
              }
       }
       ALLAVE_ declaracionVarLocal listaInst RETURN_ expre{
              if($12.t != $1){
                     yyerror("error de tipos en el return");
              }
       }
       PTOCOMA_ CLLAVE_ {
              if(verTdS){
                     mostrarTdS();
              }
              descargaContexto(niv);
              niv--;
              dvar = $<cent>3;
       }
       ;
paramForm
       : {
              $$.refe = insTdD(-1, T_VACIO);
              $$.talla = 0;
       }
       | listaParamForm {
              $$.refe = $1.refe;
              $$.talla = $1.talla - TALLA_SEGENLACES;  
       }
       ;
listaParamForm
       : tipoSimple ID_ {
              $$.refe = insTdD(-1, $1);
              $$.talla = TALLA_SEGENLACES + TALLA_TIPO_SIMPLE;
              insTdS($2, PARAMETRO, $1, niv, -$$.talla, -1);
       }
       | tipoSimple ID_ COMA_ listaParamForm{
              $$.refe = insTdD($4.refe, $1);
              $$.talla = $4.talla + TALLA_TIPO_SIMPLE;
              if(!insTdS($2, PARAMETRO, $1, niv, -$$.talla, -1)){
                     yyerror("nombre de parametro repetido");
              }
       }
       ;
declaracionVarLocal
       : 
       | declaracionVarLocal declaracionVar
       ;
listaInst
       : 
       | listaInst instruccion
       ;
instruccion
       : ALLAVE_ listaInst CLLAVE_
       | instExpre
       | instEntSal
       | instSelec
       | instIter
       ;
instExpre
       : expre PTOCOMA_
       | PTOCOMA_
       ;
instEntSal
       : READ_ APAR_ ID_ CPAR_ PTOCOMA_{
              SIMB sim = obtTdS($3);
              if(sim.t != T_ENTERO){
                     yyerror("argumento de read debe ser entero");
              }
       }
       | PRINT_ APAR_ expre CPAR_ PTOCOMA_{
              if($3.t != T_ENTERO){
                     yyerror("argumento de print debe ser entero");
              }
       }
       ;
instSelec
       : IF_ APAR_ expre CPAR_{
              if($3.t != T_LOGICO && $3.t != T_ERROR){
                     yyerror("la expresion del if debe ser de tipo logico");
              }
       } 
       instruccion ELSE_ instruccion
       ;
instIter
       : WHILE_ APAR_ expre CPAR_ 
       {
              if($3.t != T_LOGICO){
                     yyerror("argumento de while debe ser logico");
              }
       }
       instruccion{
              
       }
       ;
expre
       : expreLogic
       | ID_ IGUAL_ expre{
              SIMB sim = obtTdS($1);
              if(sim.t == T_ERROR){
                     yyerror("objeto no declarado");
              }
              else if($3.t != sim.t && $3.t != T_ERROR){
                     yyerror("error de tipos en asignacion");
              }
              else $$.t = $3.t;
       }
       | ID_ ACOR_ expre CCOR_ IGUAL_ expre{
              SIMB sim = obtTdS($1);
              if(sim.t != T_ARRAY){
                     yyerror("variable debe ser de tipo array");
              }
              else if($3.t != T_ENTERO){
                     yyerror("indice de array debe ser entero");
              }
              else if(obtTdA(sim.ref).telem != $6.t){
                     yyerror("error de tipos en asignacion de array");
              }
              else $$.t = $6.t;
       }
       | ID_ PTO_ ID_ IGUAL_ expre{
              SIMB sim = obtTdS($1);
              if(sim.t != T_RECORD){
                     yyerror("identificador debe ser struct");
                     $$.t = T_ERROR;
              }
              else {
                     CAMP cmp = obtTdR(sim.ref, $3);
                     if(cmp.t != $5.t){
                            yyerror("error en asignacion a struct");
                            $$.t = T_ERROR;
                     }
                     else $$.t = $5.t;
              }
              
       }
       ;
expreLogic
       : expreIgual{
              $$.t = $1.t;
       }
       | expreLogic opLogic expreIgual{
              if(($3.t != T_LOGICO || $1.t != T_LOGICO) && ($1.t != T_ERROR && $3.t != T_ERROR)){
                     yyerror("error en expresion logica");
                     $$.t = T_ERROR;
              }
       }
       ;
expreIgual
       : expreRel{
              $$.t = $1.t;
       }
       | expreIgual opIgual expreRel{
              if($3.t != $1.t && ($1.t != T_ERROR && $3.t != T_ERROR)){
                     yyerror("error en expresion de igualdad");
                     $$.t = T_ERROR;
              }
       }
       ;
expreRel
       : expreAd{
              $$.t = $1.t;
       }
       | expreRel opRel expreAd{
              if(($1.t != T_ENTERO || $3.t != T_ENTERO) && ($1.t != T_ERROR && $3.t != T_ERROR)){
                     yyerror("error en expresion relacional");
                     $$.t = T_ERROR;
              }
              else $$.t = T_LOGICO;
       }
       ;
expreAd
       : expreMul{
              $$.t = $1.t;
       }
       | expreAd opAd expreMul{
              $$.t = T_ENTERO;
              if(($3.t != T_ENTERO || $1.t != T_ENTERO) && ($1.t != T_ERROR && $3.t != T_ERROR)){
                     yyerror("error en expresion aditiva");
              }
       }
       ;
expreMul
       : expreUna{
              $$.t = $1.t;
       }
       | expreMul opMul expreUna{
              $$.t = T_ENTERO;
              if(($3.t != T_ENTERO || $1.t != T_ENTERO) && ($1.t != T_ERROR && $3.t != T_ERROR)){
                     yyerror("error en expresion multiplicativa");
              }
       }
       ;
expreUna
       : expreSufi{
              $$.t = $1.t;
       }
       | opUna expreUna{
              if($2.t != T_ENTERO && $1 == 0){
                     yyerror("error en expresion unaria");
                     $$.t = T_ERROR;
              }
              else if($2.t != T_LOGICO && $1 == 1){
                     yyerror("error en expresion unaria");
                     $$.t = T_ERROR;
              }
              else $$.t = $2.t;
       }
       | opIncre ID_{
              SIMB sim = obtTdS($2);
              if(sim.t != T_ENTERO){
                     yyerror("error en operador prefijo");
              }
       }
       ;
expreSufi
       : const{
              $$.t = $1.t;
       }
       | APAR_ expre CPAR_{
              $$.t = $2.t;
       }
       | ID_{
              SIMB sim = obtTdS($1);
              $$.t = sim.t;
       }
       | ID_ opIncre{
              SIMB sim = obtTdS($1);
              if(sim.t != T_ENTERO){
                     yyerror("el identificador debe ser entero");
              }
              else{
                     $$.t = T_ENTERO;
              }
       }
       | ID_ PTO_ ID_{
              SIMB sim = obtTdS($1);
              if(sim.t != T_RECORD){
                     yyerror("identificador debe ser struct");
                     $$.t = T_ERROR;
              }
              else{
                     CAMP cmp = obtTdR(sim.ref, $3);
                     if(cmp.t == T_ERROR){
                            yyerror("campo no declarado");
                     }
                     $$.t = cmp.t;
              }
       }
       | ID_ ACOR_ expre CCOR_{
              SIMB sim = obtTdS($1);
              DIM vect = obtTdA(sim.ref);
              $$.t = vect.telem;
       }
       | ID_ APAR_ paramAct CPAR_{
              SIMB sim = obtTdS($1);
              if(sim.c != FUNCION){
                     yyerror("variable debe ser una funcion");
                     $$.t = T_ERROR;
              }
              else if(cmpDom(sim.ref, $3.refe) != 1){
                     yyerror("error en el dominio de los parametros actuales");
                     $$.t = T_ERROR;
              }
              else $$.t = sim.t;
       }
       ;
const
       : CTE_{
              $$.t = T_ENTERO;
       }
       | TRUE_{
              $$.t = T_LOGICO;
       }
       | FALSE_{
              $$.t = T_LOGICO;
       }
       ;
paramAct
       : {
             $$.refe = insTdD(-1, T_VACIO); 
       }
       | listaParamAct{
              $$.refe = $1.refe;
       }
       ;
listaParamAct
       : expre{
              $$.refe = insTdD(-1, $1.t);
       }
       | expre COMA_ listaParamAct{
              $$.refe = insTdD($3.refe, $1.t);
       }
       ;
opLogic
       : OPAND_
       | OPOR_
       ;
opIgual
       : COMPIG_
       | COMPDIST_
       ;
opRel
       : COMPMAY_
       | COMPMEN_
       | COMPMAYIG_
       | COMPMENIG_
       ;
opAd
       : MAS_
       | MENOS_
       ;
opMul
       : POR_
       | DIV_
       ;
opUna
       : MAS_{
              $$ = 0;
       }
       | MENOS_{
              $$ = 0;
       }
       | OPNOT_{
              $$ = 1;
       }
       ;
opIncre
       : OPINCRE_
       | OPDECRE_
       ;

