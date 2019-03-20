#/bin/sh
SCRIPT_DIR='dirname $0'
cd $SCRIPT_DIR

#default directory is /home/5/17M40486/VS/vina
VINAHOME=c:/vina

# select or make directory to save
	echo -e "\e[1m directories list\e[m"
	ls dock_result
	echo -e "\e[1m input saved directory (example:'directory_name/' or 'directory_name')\e[m"
	cd dock_result
	read -e result1
	result2=$result1
	if [ `echo $result1 | grep /` ]; then
		RESULT=${result2:0:-1}
	# echo 'ok'
	else
		RESULT=$result1
	fi

	mkdir -v ./$RESULT
	cd ..
# select config file
	echo -e "\e[1m config files list\e[m"
	ls  config
	echo -e "\e[1m select config file with '.txt' (example:'config.txt')\e[m"
	cd config
	read -e config1
	config2=$config1
	if [ `echo $config2 | grep .txt` ]; then
		CONFIG=${config2:0:-4}
	else
		CONFIG=$config1
	fi

	echo -e "\e[1m selected config file is '${CONFIG}.txt'\e[m"
	cd ..

# select ligand directory 
	echo -e "\e[1m ligand directories list\e[m"
	ls pdbqt_ligand
	echo -e "\e[1m select ligand included directory  (example:'directory_name/' or 'directory_name')\e[m"
	cd pdbqt_ligand
	read -e ligand1
	ligand2=$ligand1
	
	if [ `echo $ligand2 | grep /` ]; then
		LIGAND=${ligand2:0:-1}
	else
		LIGAND=$ligand1
	fi

	echo -e "\e[1m selected directory is '$LIGAND'\e[m"
	cd ..

# do docking
cd ./pdbqt_ligand/$LIGAND
	for f in ./*.pdbqt*; do
	ls
#export MPLCONFIGDIR=$(mktemp -d)
		b=$(basename $LIGAND/$f .pdbqt)
		echo -e "\e[1m Processing liand '${b}'\e[m"	
		$VINAHOME/./vina --config $VINAHOME/config/${CONFIG}.txt --ligand $VINAHOME/pdbqt_ligand/$LIGAND/$f --out $VINAHOME/dock_result/$RESULT/${b}_out.pdbqt --log $VINAHOME/dock_result/$RESULT/${b}.log  

	done

#convert pdbqt to pdb
cd $VINAHOME/dock_result/$RESULT/
	for f in ./*.pdbqt; do
		b=$(basename $RESULT/$f .pdbqt)
		cut -c 1-60 ${b}.pdbqt > ${b}.pdb
		echo -e "\e[1m converted ${b}.pdbqt to ${b}.pdb\e[m"
	done
