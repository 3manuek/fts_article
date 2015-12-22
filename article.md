

```
node1 [localhost] {msandbox} (test) > show create table bookContent;
+-------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table       | Create Table                                                                                                                                                      |
+-------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| bookContent | CREATE TABLE `bookContent` (
  `paragraphid` bigint(20) DEFAULT NULL,
  `bookid` bigint(20) DEFAULT NULL,
  `content` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1 |
+-------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0,00 sec)

node1 [localhost] {msandbox} (test) > CREATE FULLTEXT INDEX ftscontent ON bookContent(content);
Query OK, 0 rows affected, 1 warning (0,98 sec)
Records: 0  Duplicates: 0  Warnings: 1

node1 [localhost] {msandbox} (test) > show warnings;
+---------+------+--------------------------------------------------+
| Level   | Code | Message                                          |
+---------+------+--------------------------------------------------+
| Warning |  124 | InnoDB rebuilding table to add column FTS_DOC_ID |
+---------+------+--------------------------------------------------+
1 row in set (0,00 sec)
```

```
node1 [localhost] {msandbox} (test) > select paragraphid from bookContent where match(content) against ("anarchy" IN BOOLEAN MODE);
+-------------+
| paragraphid |
+-------------+
|         147 |
+-------------+
1 row in set (0,00 sec)


node1 [localhost] {msandbox} (test) > select paragraphid from bookContent where match(content) against ("anarchy" IN NATURAL LANGUAGE MODE);
+-------------+
| paragraphid |
+-------------+
|         147 |
+-------------+
1 row in set (0,00 sec)

node1 [localhost] {msandbox} (test) > select count(*), max(FTS_DOC_ID) from bookContent ;
+----------+-----------------+
| count(*) | max(FTS_DOC_ID) |
+----------+-----------------+
|      870 |            1891 |
+----------+-----------------+
1 row in set (0,00 sec)

```

Matches exactly, that''s what we are not looking for.


```
node1 [localhost] {msandbox} (test) > select paragraphid, match(content) against ("anarchy" IN BOOLEAN MODE),  match(content) against ("anarchy" IN NATURAL LANGUAGE MODE), content from book
*************************** 1. row ***************************
                                                paragraphid: 147
         match(content) against ("anarchy" IN BOOLEAN MODE): 6.870564937591553
match(content) against ("anarchy" IN NATURAL LANGUAGE MODE): 6.870564937591553
                                                    content: "But coming to the other point--where a leading citizen becomes theprince of his country, not by wickedness or any intolerable violence,but by the favour of his fellow citizens--this may be called a civilprincipality: nor is genius or fortune altogether necessary to attain toit, but rather a happy shrewdness. I say then that such a principalityis obtained either by the favour of the people or by the favour of thenobles. Because in all cities these two distinct parties are found,and from this it arises that the people do not wish to be ruled noroppressed by the nobles, and the nobles wish to rule and oppress thepeople; and from these two opposite desires there arises in cities oneof three results, either a principality, self-government, or anarchy."
1 row in set (0,00 sec)
```

```
node1 [localhost] {msandbox} (test) > select paragraphid, match(content) against ("find" IN BOOLEAN MODE) as scoreBoolean,  match(content) against ("find" IN NATURAL LANGUAGE MODE) scoreNatural from bookContent where match(content) against ("find" IN NATURAL LANGUAGE MODE);
+-------------+--------------------+--------------------+
| paragraphid | scoreBoolean       | scoreNatural       |
+-------------+--------------------+--------------------+
|         109 | 2.9926140308380127 | 2.9926140308380127 |
|         152 | 2.9926140308380127 | 2.9926140308380127 |
|         264 | 2.9926140308380127 | 2.9926140308380127 |
|          24 | 1.4963070154190063 | 1.4963070154190063 |
|          41 | 1.4963070154190063 | 1.4963070154190063 |
|          69 | 1.4963070154190063 | 1.4963070154190063 |
|          96 | 1.4963070154190063 | 1.4963070154190063 |
|          98 | 1.4963070154190063 | 1.4963070154190063 |
|         132 | 1.4963070154190063 | 1.4963070154190063 |
|         155 | 1.4963070154190063 | 1.4963070154190063 |
|         206 | 1.4963070154190063 | 1.4963070154190063 |
|         207 | 1.4963070154190063 | 1.4963070154190063 |
|         209 | 1.4963070154190063 | 1.4963070154190063 |
|         228 | 1.4963070154190063 | 1.4963070154190063 |
|         235 | 1.4963070154190063 | 1.4963070154190063 |
|         243 | 1.4963070154190063 | 1.4963070154190063 |
|         263 | 1.4963070154190063 | 1.4963070154190063 |
|         276 | 1.4963070154190063 | 1.4963070154190063 |
|         280 | 1.4963070154190063 | 1.4963070154190063 |
|         303 | 1.4963070154190063 | 1.4963070154190063 |
|         306 | 1.4963070154190063 | 1.4963070154190063 |
|         324 | 1.4963070154190063 | 1.4963070154190063 |
|         327 | 1.4963070154190063 | 1.4963070154190063 |
|         361 | 1.4963070154190063 | 1.4963070154190063 |
|         372 | 1.4963070154190063 | 1.4963070154190063 |
+-------------+--------------------+--------------------+
25 rows in set (0,00 sec)

node1 [localhost] {msandbox} (test) > select paragraphid, match(content) against ("find" IN BOOLEAN MODE) as scoreBoolean,  match(content) against ("find" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) scoreNatural from bookContent where match(content) against ("find" IN NATURAL LANGUAGE MODE);
+-------------+--------------------+--------------------+
| paragraphid | scoreBoolean       | scoreNatural       |
+-------------+--------------------+--------------------+
|         109 | 2.9926140308380127 | 230.80503845214844 |
|         152 | 2.9926140308380127 |  294.7929992675781 |
|         264 | 2.9926140308380127 |  567.8131713867188 |
|          24 | 1.4963070154190063 |  299.2871398925781 |
|          41 | 1.4963070154190063 |    433.65576171875 |
|          69 | 1.4963070154190063 | 209.91278076171875 |
|          96 | 1.4963070154190063 | 457.40863037109375 |
|          98 | 1.4963070154190063 | 120.51702880859375 |
|         132 | 1.4963070154190063 |  295.8280944824219 |
|         155 | 1.4963070154190063 | 395.05401611328125 |
|         206 | 1.4963070154190063 | 406.14715576171875 |
|         207 | 1.4963070154190063 |  219.2754669189453 |
|         209 | 1.4963070154190063 |   343.243896484375 |
|         228 | 1.4963070154190063 |  303.9837341308594 |
|         235 | 1.4963070154190063 |  223.9879608154297 |
|         243 | 1.4963070154190063 |  99.28811645507812 |
|         263 | 1.4963070154190063 |  223.1049346923828 |
|         276 | 1.4963070154190063 |  456.7509460449219 |
|         280 | 1.4963070154190063 |    454.56201171875 |
|         303 | 1.4963070154190063 |   232.434326171875 |
|         306 | 1.4963070154190063 |  268.6546630859375 |
|         324 | 1.4963070154190063 | 177.97837829589844 |
|         327 | 1.4963070154190063 |  139.2750244140625 |
|         361 | 1.4963070154190063 | 411.35443115234375 |
|         372 | 1.4963070154190063 |     1464.396484375 |
+-------------+--------------------+--------------------+
25 rows in set (0,08 sec)



select paragraphid, match(content) against ("find" IN BOOLEAN MODE) as scoreBoolean,  match(content) against ("find" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) scoreNatural from bookContent where match(content) against ("find" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION);
node1 [localhost] {msandbox} (test) > select FTS_DOC_ID, match(content) against ("find" IN BOOLEAN MODE) as scoreBoolean,  match(content) against ("find" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) scoreNatural from bookContent where match(content) against ("find" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) limit 20;
+------------+--------------------+--------------------+
| FTS_DOC_ID | scoreBoolean       | scoreNatural       |
+------------+--------------------+--------------------+
|        743 | 1.5202794075012207 | 1479.1285400390625 |
|       1765 | 1.5202794075012207 | 1479.1285400390625 |
|        527 | 3.0405588150024414 |   573.650634765625 |
|       1549 | 3.0405588150024414 |   573.650634765625 |
|        757 |                  0 |  557.5772094726562 |
|       1779 |                  0 |  557.5772094726562 |
|        749 |                  0 |  516.2108764648438 |
|       1771 |                  0 |  516.2108764648438 |
|        191 | 1.5202794075012207 |  462.4548034667969 |
|       1213 | 1.5202794075012207 |  462.4548034667969 |
|        551 | 1.5202794075012207 |  461.7259826660156 |
|       1573 | 1.5202794075012207 |  461.7259826660156 |
|        559 | 1.5202794075012207 | 459.44195556640625 |
|       1581 | 1.5202794075012207 | 459.44195556640625 |
|         81 | 1.5202794075012207 |  437.7913513183594 |
|       1103 | 1.5202794075012207 |  437.7913513183594 |
|        727 |                  0 |    433.53271484375 |
|       1749 |                  0 |    433.53271484375 |
|        721 | 1.5202794075012207 |  415.5709533691406 |
|       1743 | 1.5202794075012207 |  415.5709533691406 |
+------------+--------------------+--------------------+
20 rows in set (0,10 sec)

select FTS_DOC_ID, match(content) against ("find" IN BOOLEAN MODE) as scoreBoolean,  match(content) against ("find" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) scoreNatural from bookContent where match(content) against ("find" IN NATURAL LANGUAGE MODE);

node1 [localhost] {msandbox} (test) > select FTS_DOC_ID, match(content) against ("find" IN BOOLEAN MODE) as scoreBoolean,  match(content) against ("find" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) scoreNatural from bookContent where match(content) against ("find" IN NATURAL LANGUAGE MODE) limit 20;
+------------+--------------------+--------------------+
| FTS_DOC_ID | scoreBoolean       | scoreNatural       |
+------------+--------------------+--------------------+
|        217 | 3.0405588150024414 | 233.18772888183594 |
|        303 | 3.0405588150024414 | 297.97503662109375 |
|        527 | 3.0405588150024414 |   573.650634765625 |
|       1239 | 3.0405588150024414 | 233.18772888183594 |
|       1325 | 3.0405588150024414 | 297.97503662109375 |
|       1549 | 3.0405588150024414 |   573.650634765625 |
|         47 | 1.5202794075012207 | 302.31024169921875 |
|         81 | 1.5202794075012207 |  437.7913513183594 |
|        137 | 1.5202794075012207 | 212.19143676757812 |
|        191 | 1.5202794075012207 |  462.4548034667969 |
|        195 | 1.5202794075012207 | 121.98004913330078 |
|        263 | 1.5202794075012207 | 298.98687744140625 |
|        309 | 1.5202794075012207 | 399.23016357421875 |
|        411 | 1.5202794075012207 |  410.0170593261719 |
|        413 | 1.5202794075012207 | 221.65382385253906 |
|        417 | 1.5202794075012207 | 346.75372314453125 |
|        455 | 1.5202794075012207 | 307.29156494140625 |
|        469 | 1.5202794075012207 |  226.2674560546875 |
|        485 | 1.5202794075012207 |  100.3294448852539 |
|        525 | 1.5202794075012207 | 225.51922607421875 |
+------------+--------------------+--------------------+
20 rows in set (0,11 sec)

node1 [localhost] {msandbox} (test) > select FTS_DOC_ID, match(content) against ("find*" IN BOOLEAN MODE) as scoreBoolean,  match(content) against ("find" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) scoreNatural from bookContent where match(content) against ("find" IN NATURAL LANGUAGE MODE) limit 20;
+------------+--------------------+--------------------+
| FTS_DOC_ID | scoreBoolean       | scoreNatural       |
+------------+--------------------+--------------------+
|        217 | 2.3625643253326416 | 233.18772888183594 |
|        303 | 2.3625643253326416 | 297.97503662109375 |
|        527 | 2.3625643253326416 |   573.650634765625 |
|       1239 | 2.3625643253326416 | 233.18772888183594 |
|       1325 | 2.3625643253326416 | 297.97503662109375 |
|       1549 | 2.3625643253326416 |   573.650634765625 |
|         47 | 1.1812821626663208 | 302.31024169921875 |
|         81 | 1.1812821626663208 |  437.7913513183594 |
|        137 | 1.1812821626663208 | 212.19143676757812 |
|        191 | 1.1812821626663208 |  462.4548034667969 |
|        195 | 1.1812821626663208 | 121.98004913330078 |
|        263 | 1.1812821626663208 | 298.98687744140625 |
|        309 | 1.1812821626663208 | 399.23016357421875 |
|        411 | 1.1812821626663208 |  410.0170593261719 |
|        413 | 1.1812821626663208 | 221.65382385253906 |
|        417 | 1.1812821626663208 | 346.75372314453125 |
|        455 | 1.1812821626663208 | 307.29156494140625 |
|        469 | 1.1812821626663208 |  226.2674560546875 |
|        485 | 1.1812821626663208 |  100.3294448852539 |
|        525 | 1.1812821626663208 | 225.51922607421875 |
+------------+--------------------+--------------------+
20 rows in set (0,12 sec)





```

You'll notice that the rows are ordered by default in boolean score.

You won't do this for 2 reasons:

 - you will lose the order by rank by default using the filtering match
 - You want to  associate both words.

```
node1 [localhost] {msandbox} (test) >  select paragraphid, match(content) against ("find" IN BOOLEAN MODE) as scoreBoolean,  match(content) against ("find" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) scoreNatural from bookContent where match(content) against ("find" IN NATURAL LANGUAGE MODE) or match(content) against ("the" IN NATURAL LANGUAGE MODE);
+-------------+--------------------+--------------------+
| paragraphid | scoreBoolean       | scoreNatural       |
+-------------+--------------------+--------------------+
|          24 | 1.4963070154190063 |  299.2871398925781 |
|          41 | 1.4963070154190063 |    433.65576171875 |
|          69 | 1.4963070154190063 | 209.91278076171875 |
|          96 | 1.4963070154190063 | 457.40863037109375 |
|          98 | 1.4963070154190063 | 120.51702880859375 |
|         109 | 2.9926140308380127 | 230.80503845214844 |
|         132 | 1.4963070154190063 |  295.8280944824219 |
|         152 | 2.9926140308380127 |  294.7929992675781 |
|         155 | 1.4963070154190063 | 395.05401611328125 |
|         206 | 1.4963070154190063 | 406.14715576171875 |
|         207 | 1.4963070154190063 |  219.2754669189453 |
|         209 | 1.4963070154190063 |   343.243896484375 |
|         228 | 1.4963070154190063 |  303.9837341308594 |
|         235 | 1.4963070154190063 |  223.9879608154297 |
|         243 | 1.4963070154190063 |  99.28811645507812 |
|         263 | 1.4963070154190063 |  223.1049346923828 |
|         264 | 2.9926140308380127 |  567.8131713867188 |
|         276 | 1.4963070154190063 |  456.7509460449219 |
|         280 | 1.4963070154190063 |    454.56201171875 |
|         303 | 1.4963070154190063 |   232.434326171875 |
|         306 | 1.4963070154190063 |  268.6546630859375 |
|         324 | 1.4963070154190063 | 177.97837829589844 |
|         327 | 1.4963070154190063 |  139.2750244140625 |
|         361 | 1.4963070154190063 | 411.35443115234375 |
|         372 | 1.4963070154190063 |     1464.396484375 |
+-------------+--------------------+--------------------+
25 rows in set (0,12 sec)
```


```
DOC_ID	The document ID of the row containing the word. This value might reflect the value of an ID column that you defined for the underlying table, or it can be a sequence value generated by InnoDB when the table does not contain a suitable column.

POSITION	The position of this particular instance of the word within the relevant document identified by the DOC_ID value.
```


From doc: http://dev.mysql.com/doc/refman/5.7/en/blob.html

> To define your own stopword list for all InnoDB tables, define a table with the same structure as the INNODB_FT_DEFAULT_STOPWORD > table, populate it with stopwords, and set the value of the innodb_ft_server_stopword_table option to a value in the form
> db_name/table_name before creating the full-text index

Before creating the full-text index. That means if we add a new stopword we'll need
to rebuild the index as expected.

```

node1 [localhost] {msandbox} (test) > show variables like 'innodb_ft%';
+---------------------------------+------------+
| Variable_name                   | Value      |
+---------------------------------+------------+
| innodb_ft_aux_table             |            |
| innodb_ft_cache_size            | 8000000    |
| innodb_ft_enable_diag_print     | OFF        |
| innodb_ft_enable_stopword       | ON         |
| innodb_ft_max_token_size        | 84         |
| innodb_ft_min_token_size        | 3          |
| innodb_ft_num_word_optimize     | 2000       |
| innodb_ft_result_cache_limit    | 2000000000 |
| innodb_ft_server_stopword_table |            |
| innodb_ft_sort_pll_degree       | 2          |
| innodb_ft_total_cache_size      | 640000000  |
| innodb_ft_user_stopword_table   |            |
+---------------------------------+------------+
12 rows in set (0,00 sec)

SET GLOBAL innodb_optimize_fulltext_only=ON;
OPTIMIZE TABLE bookContent;
SET GLOBAL innodb_ft_aux_table = 'test/bookContent';
SELECT * FROM information_schema.INNODB_FT_INDEX_TABLE;


node1 [localhost] {msandbox} (test) > SELECT * FROM information_schema.INNODB_FT_INDEX_TABLE limit 1;
+------+--------------+-------------+-----------+--------+----------+
| WORD | FIRST_DOC_ID | LAST_DOC_ID | DOC_COUNT | DOC_ID | POSITION |
+------+--------------+-------------+-----------+--------+----------+
| 000  |          427 |         427 |         1 |    427 |      346 |
+------+--------------+-------------+-----------+--------+----------+
1 row in set (0,05 sec)


silently fails:

SET GLOBAL innodb_optimize_fulltext_only=ON;
SELECT *
FROM information_schema.INNODB_FT_DEFAULT_STOPWORD st join information_schema.INNODB_FT_INDEX_TABLE it
  ON (st.value = it.WORD);
Empty set (0,17 sec)

node1 [localhost] {msandbox} (test) > SET GLOBAL innodb_ft_aux_table = 'test/bookContent';
Query OK, 0 rows affected (0,00 sec)

node1 [localhost] {msandbox} (test) >
node1 [localhost] {msandbox} (test) > SELECT * FROM information_schema.INNODB_FT_INDEX_TABLE where DOC_ID = '372' ;
Empty set (0,00 sec)

node1 [localhost] {msandbox} (test) > SELECT * FROM information_schema.INNODB_FT_INDEX_TABLE limit 1;
Empty set (0,00 sec)

node1 [localhost] {msandbox} (test) > DROP INDEX ftscontent ON bookContent;
Query OK, 0 rows affected (0,08 sec)
Records: 0  Duplicates: 0  Warnings: 0

node1 [localhost] {msandbox} (test) > CREATE FULLTEXT INDEX ftscontent ON bookContent(content);
Query OK, 0 rows affected (0,65 sec)
Records: 0  Duplicates: 0  Warnings: 0


```

```
node1 [localhost] {msandbox} (test) > SELECT doc_id,count(*) FROM information_schema.INNODB_FT_INDEX_TABLE where WORD IN ('find','finding','found') group by doc_id order by count(*) DESC limit 10;
+--------+----------+
| doc_id | count(*) |
+--------+----------+
|    110 |        3 |
|    168 |        3 |
|    109 |        2 |
|    236 |        2 |
|    341 |        2 |
|    196 |        2 |
|    265 |        2 |
|    369 |        2 |
|    277 |        2 |
|    153 |        2 |
+--------+----------+

node1 [localhost] {msandbox} (test) > select * from INFORMATION_SCHEMA.INNODB_FT_CONFIG limit 20;
+---------------------------+-------+
| KEY                       | VALUE |
+---------------------------+-------+
| optimize_checkpoint_limit | 180   |
| synced_doc_id             | 437   |
| stopword_table_name       |       |
| use_stopword              | 1     |
+---------------------------+-------+
4 rows in set (0,00 sec)


```


This is an important amount of space reused. Generally, you won't get words with 3 characters as
they are not worthy in most of the cases.

```
node1 [localhost] {msandbox} (test) > SELECT count(*) FROM information_schema.INNODB_FT_INDEX_TABLE ;
+----------+
| count(*) |
+----------+
|    33284 |
+----------+
1 row in set (0,11 sec)

node1 [localhost] {msandbox} (test) > SELECT count(*) FROM information_schema.INNODB_FT_INDEX_TABLE WHERE length(WORD) > 3;
+----------+
| count(*) |
+----------+
|    26905 |
+----------+
1 row in set (0,08 sec)
```

http://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_ft_user_stopword_table

you can define by table basis

```
SET GLOBAL  innodb_ft_user_stopword_table = 'test/mystops';
CREATE FULLTEXT INDEX ....
```

```
Defining an FTS_DOC_ID column at CREATE TABLE time reduces the time required to create a full-text index on a table that is already loaded with data. If an FTS_DOC_ID column is defined on a table prior to loading data, the table and its indexes do not have to be rebuilt to add the new column. If you are not concerned with CREATE FULLTEXT INDEX performance, leave out the FTS_DOC_ID column to have InnoDB create it for you. InnoDB creates a hidden FTS_DOC_ID column along with a unique index (FTS_DOC_ID_INDEX) on the FTS_DOC_ID column. If you want to create your own FTS_DOC_ID column, the column must be defined as BIGINT UNSIGNED NOT NULL and named FTS_DOC_ID (all upper case)
```



By default, tokenizing will remove words with less than 3 characters.
```
node1 [localhost] {msandbox} (test) > SELECT DISTINCT WORD FROM information_schema.INNODB_FT_INDEX_TABLE WHERE length(WORD)  < 3;
Empty set (0,07 sec)

```
Removing and from our searches:




R driver issues:

```
> source('~/git/fts_article/load.R')
Error in .local(conn, statement, ...) :
  could not run statement: Incorrect table definition; there can be only one auto column and it must be defined as a key

  node1 [localhost] {msandbox} (test) > CREATE TABLE IF NOT EXISTS bookContent(FTS_DOC_ID BIGINT UNSIGNED AUTO_INCREMENT NOT NULL, paragraphid bigint PRIMARY KEY, bookid bigint, content text);
  ERROR 1075 (42000): Incorrect table definition; there can be only one auto column and it must be defined as a key


  node1 [localhost] {msandbox} (test) > CREATE TABLE IF NOT EXISTS bookContent(FTS_DOC_ID BIGINT UNSIGNED AUTO_INCREMENT NOT NULL, paragraphid bigint, bookid bigint, content text, CONSTRAINT pk PRIMARY KEY(paragraphid, FTS_DOC_ID, bookid) );
  ERROR 1075 (42000): Incorrect table definition; there can be only one auto column and it must be defined as a key


Commented on http://dev.mysql.com/doc/refman/5.7/en/innodb-fulltext-index.html?acf=1#add-comment

Need to submit a bug on table creation time?

  When using AUTO_INCREMENT, you need to set it as PRIMARY KEY. Otherwise you get "ERROR 1075 (42000): Incorrect table definition; there can be only one auto column and it must be defined as a key".

  The doc needs to be updated setting the FTS_DOC_ID as PK:
  <pre>
  CREATE TABLE opening_lines (
  FTS_DOC_ID BIGINT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
  opening_line TEXT(500),
  author VARCHAR(200),
  title VARCHAR(200)
  ) ENGINE=InnoDB;    
  </pre>

  Also, it's concerning that using FTS_DOC_ID adds a limitation on the key definition, as it doesn't allow to create compound indexes.
  Saying that, you can't use no other column than FTS_DOC_ID if you choose to use it.

  More important, if FTS_DOC_ID is not set as AUTO_INCREMENT, the table will fail on inserting rows. However, there is no error at
  table creation time.

```
