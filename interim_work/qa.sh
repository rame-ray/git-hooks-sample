rm -fv css_inclusion_report.txt
grep Included css/*.css  > css_inclusion_report.txt


rm -fv jsp_result.txt
ls -1 jsp/*.jsp|while read file; 
do 
echo 
echo 
echo  "------------ ${file} -------------"

egrep "mvaidya|convert" ${file}.converted; 
done >> jsp_result.txt
