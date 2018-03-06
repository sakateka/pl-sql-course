select sname, city from sal where comm > (select comm from sal where sname = 'Serres')
