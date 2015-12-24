require(RMySQL)
library(ggplot2)
require(caret)


source('~/git/fts_article/load.R')

# Yeah, only for development environements
all_cons <- dbListConnections(MySQL())
for(con in all_cons) dbDisconnect(con)


# You do not want clear passwords, but is a sandbox.
con <- dbConnect(MySQL(), 
                 user="msandbox", password="msandbox", port=14901 
                 ,dbname="test", socket="/tmp/mysql_sandbox14901.sock", 
                 host="127.0.0.1")

word <- "find"

#f<-function(x) {as.character(input$filtering)}

f <- function(x) {as.character(word)}

sql <- paste("SELECT sourceTable, sum(scoreBoolean) as sumBoolean, 
        sum(scoreQE) as sumQE,
        max(scoreBoolean) as maxBoolean,
        max(scoreQE) as maxBoolean,
        avg(scoreBoolean) as avgBoolean, 
        avg(scoreQE) as avgQE,
        avg(lengthContent) avgLength,
        avg(scoreQE) / count(sourceTable) as weight,
        count(sourceTable) as countOccurrences
             FROM
             (
             SELECT \"BC\" as sourceTable, FTS_DOC_ID, match(BC.content) against (\"" ,f(x) ," \" IN BOOLEAN MODE) as scoreBoolean,
       match(BC.content) against (\""  ,f(x), "\" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) scoreQE,
       length(content) as lengthContent
FROM
        bookContent BC
WHERE
  match(BC.content) against (\"" ,f(x)," \" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION)
UNION
SELECT \"BL\" as sourceTable, FTS_DOC_ID, match(BL.content) against (\"",f(x)," \" IN BOOLEAN MODE) as scoreBoolean,
       match(BL.content) against (\"" ,f(x)," \" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION) scoreQE,
       length(content) as lengthContent
FROM
        bookContentByLine BL
WHERE
  match(BL.content) against (\"", f(x) ,"\" IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION)
) unionTable
GROUP BY sourceTable
;" , sep = "")
rs <- dbGetQuery(con, sql)


QE <- "WITH QUERY EXPANSION"
# QE <- ""

sql <- paste("
SELECT \"BC\" as sourceTable, FTS_DOC_ID, match(BC.content) against (\"" ,f(x) ," \" IN BOOLEAN MODE) as scoreBoolean,
       match(BC.content) against (\""  ,f(x), "\" IN NATURAL LANGUAGE MODE ",QE,") scoreQE,
       length(content) as lengthContent
FROM
        bookContent BC
WHERE
  match(BC.content) against (\"" ,f(x)," \" IN NATURAL LANGUAGE MODE ",QE,")
UNION
SELECT \"BL\" as sourceTable, FTS_DOC_ID, match(BL.content) against (\"",f(x)," \" IN BOOLEAN MODE) as scoreBoolean,
       match(BL.content) against (\"" ,f(x)," \" IN NATURAL LANGUAGE MODE ",QE,") scoreQE,
       length(content) as lengthContent
FROM
        bookContentByLine BL
WHERE
  match(BL.content) against (\"", f(x) ,"\" IN NATURAL LANGUAGE MODE ",QE,")
")

rs <- dbGetQuery(con, sql)

pl1 <- qplot(scoreBoolean,scoreQE, data = rs, fill = factor(sourceTable), geom = c("boxplot") )

#preOj <- preProcess(rs$scoreQE, method = c("center","scale"))  
#featurePlot(x=rs[,c("scoreQE","lengthContent")], y=rs$scoreBoolean)


