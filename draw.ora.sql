with geom as (select
  
  10 width,
   5 height

from     dual)    select     case     when  level in (1, height)
then lpad('#',  2 * width,   '#')   else    '##'
||  lpad('##', 2 *   (width  - 1)) end      square from
geom  connect  by level <=   height;/*#     ###
###      ###   ###      ###  ###    ####    ###
###      ###   ###      ###  ###      ####  ############*/

with geom as (select
  
  10 radius
  
  from dual),   calc as (select   2 *       round(  radius * sqrt(1 - /*###########*/
power(    (2 *      (radius       -         level)  + 1)              /*#*/
  / (2 *            radius)       , 2       )))     t from geom       /*#######*/
    connect         by level      <=        radius  * 2)              /*#*/
       select        lpad(       lpad(      '#', 2  * t,              /*#*/
'#'),      (2 *     radius)       + t)     circle   from              /*#*/
  geom, calc;       /*####         ############     ####              ###*/
