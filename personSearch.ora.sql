-- Personal Name Search Engine for Oracle

-- See http://xoph.co/20111007/building-a-better-search-engine/
-- for documentation and licensing information.

create or replace package personSearch authid current_user as

  type searchRecord is record(
    position number,
    id       varchar2(11)
  );
  type searchResults is table of searchRecord;
  
  -- Find people
  function find(
    searchCriteria in varchar2,
    limited        in integer
  )
  return searchResults pipelined;
    
  -- Add person search tokens
  procedure addPerson(
    id         in varchar2,
    personName in varchar2
  );
  
  -- Delete person search tokens
  procedure deletePerson(
    myPerson in varchar2
  );
  
  -- Rebuild person search token index
  procedure rebuildPeople;

  -- Metaphone
  function metaphone(
    myString in varchar2
  )
  return varchar2
  deterministic;
  
  -- Damerau-Levenshtein Distance
  -- (Barbara Boehmer)
  function dld(
    mySource in varchar2,
    myTarget in varchar2
  )
  return number
  deterministic;
  
end;
/

----------------------------------------------------------------------
----------------------------------------------------------------------

create or replace package body personSearch as

-- Private Declarations ----------------------------------------------

  type tokens is table of varchar2(40);

-- Tokeniser ---------------------------------------------------------

  function tokenise(
    myString in varchar2
  )
  return tokens
  as
    searchString varchar2(32767);
    idString     varchar2(11);
    myTokens     tokens;
  begin
    myTokens := tokens();

    idString := upper(trim(regexp_substr(myString,'(\s|^)[[:alpha:]_]{3}\d{1,8}(\s|$)')));
    searchString := trim(utl_i18n.escape_reference(
                      regexp_replace(
                        regexp_replace(myString,'((\s|^)[[:alpha:]_]{3}\d+)|[^[:alpha:]]',' '),
                        '\s+',' '),
                      'us7ascii')
                    )||' ';

    if idString is not null then
      myTokens.extend;
      myTokens(myTokens.count) := idString;
    end if;

    while searchString is not null loop
      myTokens.extend;
      myTokens(myTokens.count) := substr(searchString,1,instr(searchString,' ') - 1);
      searchString := substr(searchString,instr(searchString,' ') + 1);
    end loop;

    return myTokens;
  end tokenise;

-- Find people -------------------------------------------------------

  function find(
    searchCriteria in varchar2,
    limited        in integer
  )
  return searchResults pipelined
  as
    querySQL        varchar2(32767) := 'select token1.id from phoneticIndex token1 ';
    joinSQL         varchar2(32767) := '';
    whereSQL        varchar2(32767) := '';
    orderSQL        varchar2(32767) := '';
    myTokens        tokens;
    foundID         number := 0;
    searchTokens    number := 0;
    
    type myCursorT  is ref cursor;
    myResultsCursor myCursorT;
    resultID        searchRecord;
  begin
    myTokens := tokenise(searchCriteria);

    for i in 1..myTokens.count loop
      if foundID = 0 and regexp_instr(myTokens(i),'^[[:alpha:]_]{3}\d+$') = 1 then
        myTokens(i) := rpad(myTokens(i),11,'_');
        foundID := 1;
        
        if whereSQL is not null then
          whereSQL := ' and ' || whereSQL;
        end if;
        whereSQL := ' token1.id like ''' || myTokens(i) || ''' ' || whereSQL;
      elsif regexp_instr(myTokens(i),'^[[:alpha:]_]{3}\d+$') = 0 then
        myTokens(i) := lower(myTokens(i));
        searchTokens := searchTokens + 1;
        
        if whereSQL is not null then
          whereSQL := whereSQL || ' and ';
        end if;
        whereSQL := whereSQL || '  token' || searchTokens || '.sound like ''' || metaphone(myTokens(i)) || '%'' ';
        
        orderSQL := orderSQL || ' token' || searchTokens || '.position, personSearch.dld(token' || searchTokens || '.token,''' || myTokens(i) || '''), ';
        
        if searchTokens > 1 then
          joinSQL := joinSQL || ' join phoneticIndex token' || searchTokens || ' on token' || searchTokens || '.id = token1.id and token' || searchTokens ||'.position > token' || (searchTokens - 1) ||'.position ';
        end if;
      end if;
    end loop;
    
    if foundID = 1 and searchTokens = 0 then
      whereSQL := whereSQL || ' and token1.position = 1 ';
    end if;
    
    if whereSQL is not null and limited != 0 then
      whereSQL := whereSQL || ' and ';
    end if;
    if limited != 0 then
      whereSQL := whereSQL || ' rownum <= ' || limited || ' ';
    end if;
    
    querySQL := 'select rownum, id from (' || querySQL || joinSQL || ' where ' || whereSQL || ' order by ' || orderSQL || ' token1.id)';
    open myResultsCursor for querySQL;
  
    loop
      fetch myResultsCursor into resultID;
      exit when myResultsCursor%NOTFOUND;
      pipe row(resultID);
    end loop;
    
    close myResultsCursor;
    return;
  end find;
  
-- Add Person Search Tokens -----------------------------------------

  procedure addPerson(
    id         in varchar2,
    personName in varchar2
  )
  as
    myTokens tokens;
  begin
    myTokens := tokenise(personName);
    
    for i in 1..myTokens.count loop
      insert into phoneticIndex values (id,
                                        lower(myTokens(i)),
                                        metaphone(myTokens(i)),
                                        i);
    end loop;
  end addPerson;
  
-- Delete Person Search Tokens --------------------------------------

  procedure deletePerson(
    myPerson in varchar2
  )
  as
  begin
    delete from phoneticIndex where id=myPerson;
  end deletePerson;

-- Rebuild Person Search Token Index --------------------------------

  procedure rebuildPeople
  as
    cursor personNames is
      select id,
             forename||' '||surname personName
      from   myPeople;
  begin
    delete from phoneticIndex;
    for person in personNames loop
      addPerson(person.id,person.personName);
    end loop;
  end rebuildPeople;
  
-- Metaphone ---------------------------------------------------------

  function metaphone(
    myString in varchar2
  )
  return varchar2
  deterministic
  as
    phonic varchar2(32767);
  begin
    if myString is null then
      return null;
    end if;

    phonic := lower(myString);
    phonic := regexp_replace(phonic,'(\s|^)ae(\w*)','\1e\2');
    phonic := regexp_replace(phonic,'(\s|^)[gkp]n(\w*)','\1n\2');
    phonic := regexp_replace(phonic,'(\s|^)wr(\w*)','\1r\2');
    phonic := regexp_replace(phonic,'(\s|^)x(\w*)','\1s\2');
    phonic := regexp_replace(phonic,'(\s|^)wh(\w*)','\1w\2');
    phonic := regexp_replace(phonic,'(\w*)b(\w*)','\1B\2');
    phonic := regexp_replace(phonic,'(\w+)mB(\s|$)','\1m\2');
    phonic := regexp_replace(phonic,'(\w*)sch(\w*)','\1sK\2');
    phonic := regexp_replace(phonic,'(\w*)chr(\w*)','\1Kr\2');
    phonic := regexp_replace(phonic,'(\w*)chae(\w*)','\1K\2');
    phonic := regexp_replace(phonic,'(\w*)sc([iey])(\w*)','\1s\2\3');
    phonic := regexp_replace(phonic,'(\w*)c(ia|h)(\w*)','\1X\2\3');
    phonic := regexp_replace(phonic,'(\w*)c([iey])(\w*)','\1S\2\3');
    phonic := replace(phonic,'c','K');
    phonic := regexp_replace(phonic,'(\w*)dg([iey])(\w*)','\1J\2\3');
    phonic := replace(phonic,'d','T');
    phonic := replace(phonic,'f','F');
    phonic := regexp_replace(phonic,'(\w*)gh([aeiou]+)','\1h\2');
    phonic := regexp_replace(phonic,'(\w*)gn(eT)*(\s|$)','\1n\2\3');
    phonic := regexp_replace(phonic,'(^g)g([iey])','\1J\2');
    phonic := replace(phonic,'g','K');
    phonic := regexp_replace(phonic,'[sKX]h','X');
    phonic := replace(phonic,'ph','F');
    phonic := replace(phonic,'th','0');
    phonic := regexp_replace(phonic,'([aeiou])h([^aeiou])','\1\2');
    phonic := replace(phonic,'h','H');
    phonic := replace(phonic,'j','J');
    phonic := replace(phonic,'Kk','K');
    phonic := replace(phonic,'k','K');
    phonic := translate(phonic,'lmnpqr','LMNPKR');
    phonic := regexp_replace(phonic,'(\w*)[st]i[oa](\w*)','\1X\2');
    phonic := replace(phonic,'s','S');
    phonic := replace(phonic,'SX','X');
    phonic := regexp_replace(phonic,'(\w*)tX(\w*)','\1X\2');
    phonic := replace(phonic,'t','T');
    phonic := replace(phonic,'v','F');
    phonic := regexp_replace(phonic,'w([aeiou]|\s|$)','Wa\1');
    phonic := regexp_replace(phonic,'w([^aeiou])','\1');
    phonic := replace(phonic,'x','KS');
    phonic := regexp_replace(phonic,'y([aeiou]|\s|$)','Ya\1');
    phonic := regexp_replace(phonic,'y([^aeiou])','\1');
    phonic := replace(phonic,'z','S');
    phonic := regexp_replace(phonic,'(\w)[aeiou]+','\1');
    phonic := translate(phonic,'aeiou','AEIOU');
    phonic := regexp_replace(phonic,'(\w)\1+','\1');
    
    return phonic;
  end metaphone;
  
-- Damerau-Levenshtein Distance --------------------------------------

  function dld(
    mySource varchar2,
    myTarget varchar2
  )
  return number
  deterministic
  as
    sourceLength number := nvl(length(mySource),0);
    targetLength number := nvl(length(myTarget),0);
    type myTType is table of number index by binary_integer;
    type myArray is table of myTType index by binary_integer;
    d            myArray;
    cost         number := 0;
  begin
    if mySource = myTarget then
      return 0;
    elsif sourceLength = 0 or targetLength = 0 then
      return greatest(sourceLength,targetLength);
    elsif sourceLength = 1 and targetLength = 1 and mySource != myTarget then
      return 1;
    else
      for j in 0..targetLength loop
        d(0)(j) := j;
      end loop;
      for i in 1..sourceLength loop
        d(i)(0) := i;
        for j in 1..targetLength loop
          if substr(mySource,i,1) = substr(myTarget,j,1) then
            cost := 0;
          else
            cost := 1;
          end if;
          d(i)(j) := least(d(i-1)(j) + 1,d(i)(j-1) + 1,d(i-1)(j-1) + cost);
          if i > 1 and j > 1 and substr(mySource,i,1) = substr(myTarget,j-1,1) and substr(mySource,i-1,1) = substr(myTarget,j,1) then
            d(i)(j) := least(d(i)(j),d(i-2)(j-2) + cost);
          end if;              
        end loop;
      end loop;
      return d(sourceLength)(targetLength);
    end if;
  end dld;
end personSearch;
/

----------------------------------------------------------------------
----------------------------------------------------------------------

create table phoneticIndex(
  id          varchar2(11),
  token       varchar2(40),
  sound       varchar2(40),
  position    integer not null,
  primary key (id,sound,position)
);

create index ps_index1 on phoneticIndex(
  id,
  sound
);
  
create index ps_index2 on phoneticIndex(
  sound
);

create index ps_index3 on phoneticIndex(
  id
);

----------------------------------------------------------------------
----------------------------------------------------------------------

create or replace trigger iPhoneticIndex
  after insert
  on    myPeople for each row
begin
  personSearch.addPerson(:new.id,:new.forename || ' ' || :new.surname);
end;
/

create or replace trigger uPhoneticIndex
  after update
  on    myPeople for each row
begin
  personSearch.deletePerson(:old.id);
  personSearch.addPerson(:new.id,:new.forename || ' ' || :new.surname);
end;
/

create or replace trigger dPhoneticIndex
  after delete
  on    myPeople for each row
begin
  personSearch.deletePerson(:old.id);
end;
/

----------------------------------------------------------------------
----------------------------------------------------------------------
  
exec personSearch.rebuildPeople;
