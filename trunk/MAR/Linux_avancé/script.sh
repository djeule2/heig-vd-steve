version_noyau="linux-2.6.13.3"
extension=".tar.bz2"
cd /home/steve/HEIG-VD/MAR/Laboratoires/Labo_Linux_avance



if [ -f $version_noyau$extension ]
then 
	echo "Le noyau a déjà été téléchargé"
else		
	wget http://www.kernel.org/pub/linux/kernel/v2.6/$version_noyau$extension
	bunzip2 $version_noyau$extension
	tar -xf ${version_noyau}.tar
fi 


echo "Nombre de fichiers *.c: "
find ./$version_noyau -name "*.c" | wc -l
echo "Nombre total de lignes de code: " 
wc -l $(find ./$version_noyau -name "*.c") | grep total | awk -F" " '{print $1}'
