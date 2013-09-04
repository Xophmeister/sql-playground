with message as (
  select 'Hello World' text from dual
),
font as (
  select 'A' c, 1 r, '  ####  ' sl from dual union all
  select 'A' c, 2 r, ' ##  ## ' sl from dual union all
  select 'A' c, 3 r, '########' sl from dual union all
  select 'A' c, 4 r, '##    ##' sl from dual union all
  select 'A' c, 5 r, '##    ##' sl from dual union all
  select 'B' c, 1 r, '######  ' sl from dual union all
  select 'B' c, 2 r, '##   ## ' sl from dual union all
  select 'B' c, 3 r, '######  ' sl from dual union all
  select 'B' c, 4 r, '##    ##' sl from dual union all
  select 'B' c, 5 r, '####### ' sl from dual union all
  select 'C' c, 1 r, ' ###### ' sl from dual union all
  select 'C' c, 2 r, '##    ##' sl from dual union all
  select 'C' c, 3 r, '##      ' sl from dual union all
  select 'C' c, 4 r, '##    ##' sl from dual union all
  select 'C' c, 5 r, ' ###### ' sl from dual union all
  select 'D' c, 1 r, '####### ' sl from dual union all
  select 'D' c, 2 r, '##    ##' sl from dual union all
  select 'D' c, 3 r, '##    ##' sl from dual union all
  select 'D' c, 4 r, '##    ##' sl from dual union all
  select 'D' c, 5 r, '####### ' sl from dual union all
  select 'E' c, 1 r, '########' sl from dual union all
  select 'E' c, 2 r, '##      ' sl from dual union all
  select 'E' c, 3 r, '######  ' sl from dual union all
  select 'E' c, 4 r, '##      ' sl from dual union all
  select 'E' c, 5 r, '########' sl from dual union all
  select 'F' c, 1 r, '########' sl from dual union all
  select 'F' c, 2 r, '##      ' sl from dual union all
  select 'F' c, 3 r, '######  ' sl from dual union all
  select 'F' c, 4 r, '##      ' sl from dual union all
  select 'F' c, 5 r, '##      ' sl from dual union all
  select 'G' c, 1 r, ' ###### ' sl from dual union all
  select 'G' c, 2 r, '##      ' sl from dual union all
  select 'G' c, 3 r, '##  ####' sl from dual union all
  select 'G' c, 4 r, '##    ##' sl from dual union all
  select 'G' c, 5 r, ' #######' sl from dual union all
  select 'H' c, 1 r, '##    ##' sl from dual union all
  select 'H' c, 2 r, '##    ##' sl from dual union all
  select 'H' c, 3 r, '########' sl from dual union all
  select 'H' c, 4 r, '##    ##' sl from dual union all
  select 'H' c, 5 r, '##    ##' sl from dual union all
  select 'I' c, 1 r, '########' sl from dual union all
  select 'I' c, 2 r, '   ##   ' sl from dual union all
  select 'I' c, 3 r, '   ##   ' sl from dual union all
  select 'I' c, 4 r, '   ##   ' sl from dual union all
  select 'I' c, 5 r, '########' sl from dual union all
  select 'J' c, 1 r, '########' sl from dual union all
  select 'J' c, 2 r, '      ##' sl from dual union all
  select 'J' c, 3 r, '      ##' sl from dual union all
  select 'J' c, 4 r, '##    ##' sl from dual union all
  select 'J' c, 5 r, ' ###### ' sl from dual union all
  select 'K' c, 1 r, '##    ##' sl from dual union all
  select 'K' c, 2 r, '##   ## ' sl from dual union all
  select 'K' c, 3 r, '#####   ' sl from dual union all
  select 'K' c, 4 r, '##   ## ' sl from dual union all
  select 'K' c, 5 r, '##    ##' sl from dual union all
  select 'L' c, 1 r, '##      ' sl from dual union all
  select 'L' c, 2 r, '##      ' sl from dual union all
  select 'L' c, 3 r, '##      ' sl from dual union all
  select 'L' c, 4 r, '##      ' sl from dual union all
  select 'L' c, 5 r, '########' sl from dual union all
  select 'M' c, 1 r, '##    ##' sl from dual union all
  select 'M' c, 2 r, '###  ###' sl from dual union all
  select 'M' c, 3 r, '## ## ##' sl from dual union all
  select 'M' c, 4 r, '##    ##' sl from dual union all
  select 'M' c, 5 r, '##    ##' sl from dual union all
  select 'N' c, 1 r, '##    ##' sl from dual union all
  select 'N' c, 2 r, '###   ##' sl from dual union all
  select 'N' c, 3 r, '## ## ##' sl from dual union all
  select 'N' c, 4 r, '##   ###' sl from dual union all
  select 'N' c, 5 r, '##    ##' sl from dual union all
  select 'O' c, 1 r, ' ###### ' sl from dual union all
  select 'O' c, 2 r, '##    ##' sl from dual union all
  select 'O' c, 3 r, '##    ##' sl from dual union all
  select 'O' c, 4 r, '##    ##' sl from dual union all
  select 'O' c, 5 r, ' ###### ' sl from dual union all
  select 'P' c, 1 r, '####### ' sl from dual union all
  select 'P' c, 2 r, '##    ##' sl from dual union all
  select 'P' c, 3 r, '####### ' sl from dual union all
  select 'P' c, 4 r, '##      ' sl from dual union all
  select 'P' c, 5 r, '##      ' sl from dual union all
  select 'Q' c, 1 r, ' ###### ' sl from dual union all
  select 'Q' c, 2 r, '##    ##' sl from dual union all
  select 'Q' c, 3 r, '##    ##' sl from dual union all
  select 'Q' c, 4 r, '##  ### ' sl from dual union all
  select 'Q' c, 5 r, ' #### ##' sl from dual union all
  select 'R' c, 1 r, '####### ' sl from dual union all
  select 'R' c, 2 r, '##    ##' sl from dual union all
  select 'R' c, 3 r, '####### ' sl from dual union all
  select 'R' c, 4 r, '##    ##' sl from dual union all
  select 'R' c, 5 r, '##    ##' sl from dual union all
  select 'S' c, 1 r, ' ###### ' sl from dual union all
  select 'S' c, 2 r, '###   ##' sl from dual union all
  select 'S' c, 3 r, '  ####  ' sl from dual union all
  select 'S' c, 4 r, '##   ###' sl from dual union all
  select 'S' c, 5 r, ' ###### ' sl from dual union all
  select 'T' c, 1 r, '########' sl from dual union all
  select 'T' c, 2 r, '   ##   ' sl from dual union all
  select 'T' c, 3 r, '   ##   ' sl from dual union all
  select 'T' c, 4 r, '   ##   ' sl from dual union all
  select 'T' c, 5 r, '   ##   ' sl from dual union all
  select 'U' c, 1 r, '##    ##' sl from dual union all
  select 'U' c, 2 r, '##    ##' sl from dual union all
  select 'U' c, 3 r, '##    ##' sl from dual union all
  select 'U' c, 4 r, '##    ##' sl from dual union all
  select 'U' c, 5 r, ' ###### ' sl from dual union all
  select 'V' c, 1 r, '##    ##' sl from dual union all
  select 'V' c, 2 r, '##    ##' sl from dual union all
  select 'V' c, 3 r, ' ##  ## ' sl from dual union all
  select 'V' c, 4 r, '  ####  ' sl from dual union all
  select 'V' c, 5 r, '   ##   ' sl from dual union all
  select 'W' c, 1 r, '##    ##' sl from dual union all
  select 'W' c, 2 r, '##    ##' sl from dual union all
  select 'W' c, 3 r, '## ## ##' sl from dual union all
  select 'W' c, 4 r, '###  ###' sl from dual union all
  select 'W' c, 5 r, '##    ##' sl from dual union all
  select 'X' c, 1 r, '##    ##' sl from dual union all
  select 'X' c, 2 r, ' ##  ## ' sl from dual union all
  select 'X' c, 3 r, '  ####  ' sl from dual union all
  select 'X' c, 4 r, ' ##  ## ' sl from dual union all
  select 'X' c, 5 r, '##    ##' sl from dual union all
  select 'Y' c, 1 r, '##    ##' sl from dual union all
  select 'Y' c, 2 r, ' ##  ## ' sl from dual union all
  select 'Y' c, 3 r, '  ####  ' sl from dual union all
  select 'Y' c, 4 r, '   ##   ' sl from dual union all
  select 'Y' c, 5 r, '   ##   ' sl from dual union all
  select 'Z' c, 1 r, '########' sl from dual union all
  select 'Z' c, 2 r, '    ##  ' sl from dual union all
  select 'Z' c, 3 r, '   ##   ' sl from dual union all
  select 'Z' c, 4 r, ' ##     ' sl from dual union all
  select 'Z' c, 5 r, '########' sl from dual union all
  select ' ' c, 1 r, '    '     sl from dual union all
  select ' ' c, 2 r, '    '     sl from dual union all
  select ' ' c, 3 r, '    '     sl from dual union all
  select ' ' c, 4 r, '    '     sl from dual union all
  select ' ' c, 5 r, '    '     sl from dual
),
stream as (
  select     ceil(level / 5) l,
             mod(level - 1, 5) + 1 r,
             substr(text, ceil(level / 5), 1) c
  from       message
  connect by level <= length(text) * 5
),
figlet as (
  select    stream.l,
            stream.r,
            nvl(font.sl, '????????') sl
  from      stream
  left join font
  on        font.c = upper(stream.c)
  and       font.r = stream.r
)
select   listagg(sl, '  ') within group (order by l) text
from     figlet
group by r;
