rm -fv css_inclusion_report.txt js_inclusion_report.txt jsp_result.txt

grep Included css/*.css  > css_inclusion_report.txt
grep Included js/*.js  > js_inclusion_report.txt


ls -1 jsp/*.jsp|while read file; 
do 
echo 
echo 
echo  "------------ ${file} -------------"

egrep -n "mvaidya|convert" ${file}
done >> jsp_result.txt
