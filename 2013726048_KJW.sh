#!/bin/bash

tput civis
declare -i cursor=2
declare -a filelist
declare -i total_num
declare -i dir_num
declare -i nor_num
declare -i spe_num
declare loadfile

makelist()
{
   unset filelist
   total_num=0
   dir_num=-1
   nor_num=0
   spe_num=0
   filelist[0]=".."

   ls_result=`ls -X1`

   for s in $ls_result
      do
      filelist=(${filelist[@]} $s)
      total_num=$total_num+1
      done
}

listload()
{
   declare -i index=2
   for s in ${filelist[@]}
      do
	  if [[ ${#s} -gt 26 ]]; then
	  	filename=${s:0:23}...
	  else
	  	filename=$s
	  fi
      tput cup $index 1 
      if [ "`file -b ${s}`" == "directory" ]; then
      	echo [34m$filename
      	dir_num=$dir_num+1
      else
      	if [ "${s##*.}" == "sh" ] || [ "${s##*.}" == "exe" ]; then
      		echo [32m$filename
      		spe_num=$spe_num+1
      	elif [ "${s##*.}" == "zip" ] || [ "${s##*.}" == "gz" ]; then
            echo [31m$filename
      		spe_num=$spe_num+1
      	else
      		echo [0m$filename
      		nor_num=$nor_num+1
      	fi
      fi
      index=${index}+1
	  unset filename
   done
}

cursorload()
{
   if [[ ${#filelist[${cursor}-2]} -gt 26 ]]; then
   		filename=${filelist[${cursor}-2]:0:23}...
   else
   		filename=${filelist[${cursor}-2]}
   fi
   tput cup $cursor 1
   if [ "`file -b ${filelist[${cursor}-2]}`" == "directory" ]; then
           echo [44m${filename}
   else
           if [ "${filelist[${cursor}-2]##*.}" == "sh" ] || [ "${filelist[${cursor}-2]##*.}" == "exe" ]; then
                   echo [42m${filename}
           elif [ "${filelist[${cursor}-2]##*.}" == "zip" ] || [ "${filelist[${cursor}-2]##*.}" == "gz" ]; then
                  echo [41m${filename}
           else
                  echo [7m${filename}
           fi
   fi
   unset filename
}

fileload()
{
	if [[ $loadfile != "" ]]; then
	    declare -i line_num=1
		declare -i point=2
	    while read line
	    do
		if [ $line_num -le 28 ]; then
		    tput cup $point 29
			if  [[ ${#line} -gt 42 ]]; then
			    echo [0m$line_num ${line:0:42}
			else
				echo [0m$line_num $line
			fi
		    line_num=${line_num}+1
			point=${point}+1
		fi
	    done < $loadfile
	    unset line_num
		unset point
	fi
}


infomationload()
{
   file=${filelist[${cursor}-2]}
   tput cup 31 1
   echo [0m"File name : "$file
   tput cup 32 1
   if [ "`file -b ${file}`" == "directory" ]; then
      echo [34m"File type : directory"
   else
      if [ "${file##*.}" == "sh" ] || [ "${file##*.}" == "exe" ]; then
         echo [32m"File type : execute file"
      elif [ "${file##*.}" == "zip" ] || [ "${file##*.}" == "gz" ]; then
         echo [31m"File type : compressed file"
      else
         echo [0m"File type : regular file"
      fi
   fi
   tput cup 33 1
   echo [0m"File size : "`stat -c %s $file`
   tput cup 34 1
   time=`stat -c %w $file`
   if [ $time == "-" ]; then
      time=`stat -c %z $file`
   fi
   echo "Creation time : "$time
   tput cup 35 1
   echo "Permission : "`stat -c %a $file`
   tput cup 36 1
   echo "Absolute path : "`pwd`"/"$file
   unset file
   unset time
}

numload()
{
   tput cup 40 1
   size=`du -s . | cut -f1`
   tput cup 38 12
   echo [0m$total_num" total  "$dir_num" dir  "$nor_num" file  "$spe_num" sfile  "$size" byte"
}

screenload()
{
   clear
   echo "================================================ 2013726048 JaeWon Kim  ================================================"
   echo "========================================================= List ========================================================="
   for((i=0;i<28;i++))
   do
   	echo "|                          |                                             |                                             |"
   done
   echo "====================================================== Infomation ======================================================"
   for((i=0;i<6;i++))
   do
   	echo "|                                                                                                                      |"
   done
   echo "========================================================= Total ========================================================"
   echo "|                                                                                                                      |"
   echo "========================================================== End ========================================================="
   makelist
   listload
   cursorload
   fileload
   infomationload
   numload
   tput cup 40 1
   echo [0m ""
}

while [ true ]; do
	screenload
	read -n 1 key
		if [ $key ==  ]; then
			read -n 1 key
			if [ $key == "[" ]; then
				read -n 1 key
				if [ $key == "A" ]; then
					if [ $cursor -gt 2 ]; then
						cursor=${cursor}-1
						unset loadfile
					fi
				elif [ $key == "B" ]; then
					unset max
					declare -i max=${total_num}+2
					if [ $cursor -lt $max ]; then
						cursor=${cursor}+1
						unset loadfile
					fi
				fi
			fi
		elif [[ $key = "" ]]; then
			if [ "`file -b ${filelist[${cursor}-2]}`" == "directory" ]; then
				cd ${filelist[${cursor}-2]}
				cursor=2
				unset loadfile
			elif [ "${filelist[${cursor}-2]##*.}" != "zip" ] && [ "${filelist[${cursor}-2]##*.}" != "gz" ]; then
				loadfile=${filelist[${cursor}-2]}
			fi
		fi
done			
