p5-Net-ZKMon
============

Net::ZKMon(3)         User Contributed Perl Documentation        Net::ZKMon(3)


NAME
============
       Net::ZKMon
       
DESCRIPTION
============
       Description :
         A wrapper module around Zookeeper's 4 letter command words.
         The intention is to use the abstract methods and have the resultant
         data available in perl's scalar reference/hash ;
         thus reducing the parsing overhead involved in the scripts.

REQUIRES
========
       IO::Socket

METHODS
=======
   new
       
       $this->new();


   conf
   
        $this->conf();


   mntr
        
        $this->mntr();


   stat
        
        $this->stat();


   envi
        
        $this->envi();


SEE ALSO
========

   Zookeeper 4 letter commands : http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_zkCommands

perl v5.12.3                      2012-09-30                     Net::ZKMon(3)