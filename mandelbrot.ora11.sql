-- The Mandelbrot set...in a single SQL SELECT
-- Christopher Harrison, 2013

with params as (
  select

    -- Output Size (Characters)
    99 width,
    33 height,
    
    -- Top-Left and Bottom-Right Corners of Complex Plane
    -2 x1,  1 y1,
     1 x2, -1 y2
   
  from dual
),
plane as (
  select x, y,
         (mx * x) + cx ReC,
         (my * y) + cy ImC,
         0 ReZ0, 0 ImZ0,
         0 ReZ,  0 ImZ,
         0 n
  from   (
           select     ceil(level / height) x,
                      mod(level - 1, height) + 1 y,
                      (x1 - x2) / (1 - width) mx,
                      (x2 - (x1 * width)) / (1 - width) cx,
                      (y1 - y2) / (1 - height) my,
                      (y2 - (y1 * height)) / (1 - height) cy
           from       params
           connect by level <= width * height
         )
),
mandelbrot as (
  select x, y,
         ReC, ImC,
         n
  from   plane
  model
    partition by (x, y)
    dimension by (1 as i)
    measures (ReC, ImC, ReZ0, ImZ0, ReZ, ImZ, n)
    rules update iterate (100) until (power(ReZ[1], 2) + power(ImZ[1], 2) > 4) (
      ReZ0[1] = ReZ[1], ImZ0[1] = ImZ[1],                        -- z[n]
      ReZ[1]  = power(ReZ0[1], 2) - power(ImZ0[1], 2) + ReC[1],  -- Re(z[n+1])
      ImZ[1]  = (2 * ReZ0[1] * ImZ0[1]) + ImC[1],                -- Im(z[n+1])
      n[1]    = iteration_number + 1
    )
)
select   listagg(case
           when n = 100 then ' '
           when n = 1   then '.'
           when n = 2   then ''''
           when n = 3   then ','
           when n = 4   then ';'
           when n = 5   then '"'
           when n = 6   then 'o'
           when n = 7   then 'O'
           when n = 8   then '%'
           when n = 9   then '8'
           when n = 10  then '@'
           when n > 10  then '#'
         end) within group (order by x) mandelbrot
from     mandelbrot
group by y
order by y;

/* Example Output *********************************************************************************

.........'''''''',,,,,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;""""oo%@#8@##o";;;;;;;,,,,,,,'''''''''''''''''
........''''''',,,,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;;;""""oOO%@###8Ooo"";;;;;;;,,,,,,,'''''''''''''''
.......'''''',,,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;;;;""""oo%@###  ##88o"""";;;;;;;,,,,,,,'''''''''''''
......''''',,,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;;;""""oooO%8# #    ###%oo""""";;;;;,,,,,,,,'''''''''''
.....'''',,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;;;"""oooooOOO%@#       ##%OOooo""""";;;,,,,,,,,,'''''''''
....''',,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;""""o@88#@%%8@@@###     ###@8@#%OooOO#O";;,,,,,,,,,,'''''''
....'',,,,,,,,,,,,,,,,,,,,,,;;;;;;;"""""""ooO@######## #              ##88#@##8%";;,,,,,,,,,,''''''
...'',,,,,,,,,,,,,,,,,,,,,;;;;""""""""""oooO%8##                         #   ##O"";;,,,,,,,,,,'''''
...',,,,,,,,,,,,,,,,,,;;;;"""""""""""oooooO8#####                           ##Ooo"";;,,,,,,,,,,''''
..',,,,,,,,,,,,,,;;;;;"%Ooooooo""oooooOOO%8#  #                             ##%Oo"";;;,,,,,,,,,,'''
..,,,,,,,,,;;;;;;;;"""oO#8%OOO%8#%OOOOO%%8##                                 ####O";;;,,,,,,,,,,,''
.',,,,,;;;;;;;;;"""""oo%8###########@888@###                                  ##8o";;;;,,,,,,,,,,''
.,,,;;;;;;;;;;""""""ooOO8@## ##     #######                                   ##8o";;;;,,,,,,,,,,,'
.,;;;;;;;;;;"""""""oOO%@####           ###                                    #@Oo";;;;;,,,,,,,,,,'
.;;;;;;;;;""oooooO%##@####              #                                     #%o"";;;;;,,,,,,,,,,'
.;"""ooOOOooooOOO%8#### #                                                    #Ooo"";;;;;,,,,,,,,,,'
                                                                          ##@%Ooo"";;;;;,,,,,,,,,,,
.;"""ooOOOooooOOO%8#### #                                                    #Ooo"";;;;;,,,,,,,,,,'
.;;;;;;;;;""oooooO%##@####              #                                     #%o"";;;;;,,,,,,,,,,'
.,;;;;;;;;;;"""""""oOO%@####           ###                                    #@Oo";;;;;,,,,,,,,,,'
.,,,;;;;;;;;;;""""""ooOO8@## ##     #######                                   ##8o";;;;,,,,,,,,,,,'
.',,,,,;;;;;;;;;"""""oo%8###########@888@###                                  ##8o";;;;,,,,,,,,,,''
..,,,,,,,,,;;;;;;;;"""oO#8%OOO%8#%OOOOO%%8##                                 ####O";;;,,,,,,,,,,,''
..',,,,,,,,,,,,,,;;;;;"%Ooooooo""oooooOOO%8#  #                             ##%Oo"";;;,,,,,,,,,,'''
...',,,,,,,,,,,,,,,,,,;;;;"""""""""""oooooO8#####                           ##Ooo"";;,,,,,,,,,,''''
...'',,,,,,,,,,,,,,,,,,,,,;;;;""""""""""oooO%8##                         #   ##O"";;,,,,,,,,,,'''''
....'',,,,,,,,,,,,,,,,,,,,,,;;;;;;;"""""""ooO@######## #              ##88#@##8%";;,,,,,,,,,,''''''
....''',,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;""""o@88#@%%8@@@###     ###@8@#%OooOO#O";;,,,,,,,,,,'''''''
.....'''',,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;;;"""oooooOOO%@#       ##%OOooo""""";;;,,,,,,,,,'''''''''
......''''',,,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;;;""""oooO%8# #    ###%oo""""";;;;;,,,,,,,,'''''''''''
.......'''''',,,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;;;;""""oo%@###  ##88o"""";;;;;;;,,,,,,,'''''''''''''
........''''''',,,,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;;;""""oOO%@###8Ooo"";;;;;;;,,,,,,,'''''''''''''''
.........'''''''',,,,,,,,,,,,,,,,,,,,,,,,,,,;;;;;;;;;""""oo%@#8@##o";;;;;;;,,,,,,,'''''''''''''''''

******************************************************************************************* Xoph */
