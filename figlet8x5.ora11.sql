with message as (
  select 'Hello World' text from dual
),
font as (
  select 'A' l,  60 r1, 102 r2, 255 r3, 195 r4, 195 r5 from dual union all
  select 'B' l, 252 r1, 198 r2, 252 r3, 195 r4, 254 r5 from dual union all
  select 'C' l, 126 r1, 195 r2, 192 r3, 195 r4, 126 r5 from dual union all
  select 'D' l, 254 r1, 195 r2, 195 r3, 195 r4, 254 r5 from dual union all
  select 'E' l, 255 r1, 192 r2, 252 r3, 192 r4, 255 r5 from dual union all
  select 'F' l, 255 r1, 192 r2, 252 r3, 192 r4, 192 r5 from dual union all
  select 'G' l, 126 r1, 192 r2, 207 r3, 195 r4, 127 r5 from dual union all
  select 'H' l, 195 r1, 195 r2, 255 r3, 195 r4, 195 r5 from dual union all
  select 'I' l, 255 r1,  24 r2,  24 r3,  24 r4, 255 r5 from dual union all
  select 'J' l, 255 r1,   3 r2,   3 r3, 195 r4, 126 r5 from dual union all
  select 'K' l, 195 r1, 198 r2, 248 r3, 198 r4, 195 r5 from dual union all
  select 'L' l, 192 r1, 192 r2, 192 r3, 192 r4, 255 r5 from dual union all
  select 'M' l, 195 r1, 231 r2, 219 r3, 195 r4, 195 r5 from dual union all
  select 'N' l, 195 r1, 227 r2, 219 r3, 199 r4, 195 r5 from dual union all
  select 'O' l, 126 r1, 195 r2, 195 r3, 195 r4, 126 r5 from dual union all
  select 'P' l, 254 r1, 195 r2, 254 r3, 192 r4, 192 r5 from dual union all
  select 'Q' l, 126 r1, 195 r2, 195 r3, 206 r4, 123 r5 from dual union all
  select 'R' l, 254 r1, 195 r2, 254 r3, 195 r4, 195 r5 from dual union all
  select 'S' l, 126 r1, 227 r2,  60 r3, 199 r4, 126 r5 from dual union all
  select 'T' l, 255 r1,  24 r2,  24 r3,  24 r4,  24 r5 from dual union all
  select 'U' l, 195 r1, 195 r2, 195 r3, 195 r4, 126 r5 from dual union all
  select 'V' l, 195 r1, 195 r2, 102 r3,  60 r4,  24 r5 from dual union all
  select 'W' l, 195 r1, 195 r2, 219 r3, 231 r4, 195 r5 from dual union all
  select 'X' l, 195 r1, 102 r2,  60 r3, 102 r4, 195 r5 from dual union all
  select 'Y' l, 195 r1, 102 r2,  60 r3,  24 r4,  24 r5 from dual union all
  select 'Z' l, 255 r1,  12 r2,  24 r3,  96 r4, 255 r5 from dual union all
  select ' ' l,   0 r1,   0 r2,   0 r3,   0 r4,   0 r5 from dual 
),
flatFont as (
  select  l, r, data
  from    font
  unpivot (data for r in (r1 as 1, r2 as 2, r3 as 3, r4 as 4, r5 as 5))
),
flatBitmap as (
  select     l, r, b,
             decode(bitand(data, power(2, 8 - b)), 0, ' ', '#') data
  from       flatFont
  cross join (select     level b
              from       dual
              connect by level <= 8) b
),
bitFont as (
  select   l, r,
           listagg(data) within group (order by b) sl
  from     flatBitmap
  group by l, r
),
stream as (
  select     ceil(level / 5) i,
             mod(level - 1, 5) + 1 r,
             substr(text, ceil(level / 5), 1) l
  from       message
  connect by level <= length(text) * 5
),
figlet as (
  select    stream.i,
            stream.r,
            nvl(bitFont.sl, '????????') sl
  from      stream
  left join bitFont
  on        bitFont.l = upper(stream.l)
  and       bitFont.r = stream.r
)
select   listagg(sl, ' ') within group (order by i) text
from     figlet
group by r
order by r;
