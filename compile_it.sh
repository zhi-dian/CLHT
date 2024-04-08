git clone https://github.com/LPD-EPFL/ssmem ./external/ssmem
git clone https://github.com/trigonak/sspfd ./external/sspfd
mkdir external/lib &> /dev/null;

cd ./external/ssmem;
git pull;
#make libssmem.a
cc -D_GNU_SOURCE -c src/ssmem.c -O3 -Wall -I./include;
echo Archive name = libssmem.a;
ar -r libssmem.a ssmem.o ;
rm -f *.o;
#=================

cp libssmem.a ../lib;
cp include/ssmem.h ../include;
cd -;

cd ./external/sspfd;
git pull;
#make libsspfd.a;=======
gcc -D_GNU_SOURCE -c sspfd.c -O3 -Wall -L./ 
echo Archive name = libsspfd.a
ar -r libsspfd.a sspfd.o
rm -f *.o
#=================
#The above create /lib, /ssmem, /sspfd in /external 

cp libsspfd.a ../lib;
cp sspfd.h ../include;
cd -;

#need to have .include/clht_res.h
gcc -D_GNU_SOURCE -O3 -DADD_PADDING -DDEFAULT  -Wall -I./include -I./external/include -o clht_gc.o -c src/clht_gc.c;
gcc -D_GNU_SOURCE -O3 -DADD_PADDING -DDEFAULT  -Wall -I./include -I./external/include -o clht_lb.o -c src/clht_lb.c;

echo Archive name = libclht.a;
ar -d libclht.a *;
ar -r libclht.a clht_lb.o clht_gc.o;
gcc -DNO_RESIZE -D_GNU_SOURCE -O3 -DADD_PADDING -DDEFAULT  -Wall -I./include -I./external/include bmarks/test_mem.c   -o clht_lb -L./external/lib -L. -lrt -lpthread -lm  -lclht -lssmem -lclht;