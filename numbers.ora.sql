with English as  (select 0  x, null        en from dual union
                  select 1  x, 'One'       en from dual union
                  select 2  x, 'Two'       en from dual union
                  select 3  x, 'Three'     en from dual union
                  select 4  x, 'Four'      en from dual union
                  select 5  x, 'Five'      en from dual union
                  select 6  x, 'Six'       en from dual union
                  select 7  x, 'Seven'     en from dual union
                  select 8  x, 'Eight'     en from dual union
                  select 9  x, 'Nine'      en from dual union
                  select 10 x, 'Ten'       en from dual union
                  select 11 x, 'Eleven'    en from dual union
                  select 12 x, 'Twelve'    en from dual union
                  select 13 x, 'Thirteen'  en from dual union
                  select 14 x, 'Fourteen'  en from dual union
                  select 15 x, 'Fifteen'   en from dual union
                  select 16 x, 'Sixteen'   en from dual union
                  select 17 x, 'Seventeen' en from dual union
                  select 18 x, 'Eighteen'  en from dual union
                  select 19 x, 'Nineteen'  en from dual union
                  select 20 x, 'Twenty'    en from dual union
                  select 30 x, 'Thirty'    en from dual union
                  select 40 x, 'Forty'     en from dual union
                  select 50 x, 'Fifty'     en from dual union
                  select 60 x, 'Sixty'     en from dual union
                  select 70 x, 'Seventy'   en from dual union
                  select 80 x, 'Eighty'    en from dual union
                  select 90 x, 'Ninety'    en from dual),
     SplitNum as (select MyNumber,
                         trunc(MyNumber/1000)          M,
                         trunc(mod(MyNumber,1000)/100) C,
                         trunc(mod(MyNumber,100)/10)   X,
                         mod(MyNumber,10)              I
                  from  (select     level MyNumber
                         from       dual
                         connect by level <= 10000))
select    SplitNum.MyNumber,
          trim(nvl2(alpha.en,alpha.en||' Thousand',null)||
         (case when (SplitNum.M > 0 and SplitNum.C = 0 and (SplitNum.X > 0 OR SplitNum.I > 0))
               then ''
               else ' '
          end)||
          nvl2(beta.en,beta.en||' Hundred',null)||' '||
         (case when ((SplitNum.M > 0 or SplitNum.C > 0) and (SplitNum.X > 0 OR SplitNum.I > 0)) then 'and ' end)||
          nvl2(epsilon.en,epsilon.en,gamma.en||' '||delta.en)) English
from      SplitNum
left join English alpha
on        alpha.x = SplitNum.M
left join English beta
on        beta.x = SplitNum.C
left join English gamma
on        gamma.x = SplitNum.X*10
left join English delta
on        delta.x = SplitNum.I
left join English epsilon
on        epsilon.x = (SplitNum.X*10)+SplitNum.I
order by  MyNumber;
