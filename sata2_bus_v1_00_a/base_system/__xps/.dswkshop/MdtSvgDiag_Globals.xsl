<?xml version="1.0" standalone="no"?>
<xsl:stylesheet version="1.0"
           xmlns:svg="http://www.w3.org/2000/svg"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:exsl="http://exslt.org/common"
           xmlns:xlink="http://www.w3.org/1999/xlink">
                


<xsl:variable name="G_BIFTYPES">

	<BIFTYPE TYPE="SLAVE"/>
	<BIFTYPE TYPE="MASTER"/>
	<BIFTYPE TYPE="MASTER_SLAVE"/>
	
	<BIFTYPE TYPE="TARGET"/>
	<BIFTYPE TYPE="INITIATOR"/>
	
	<BIFTYPE TYPE="MONITOR"/>
	
	<BIFTYPE TYPE="USER"/>
	<BIFTYPE TYPE="TRANSPARENT"/>
	
</xsl:variable>	
<xsl:variable name="G_BIFTYPES_NUMOF" select="count(exsl:node-set($G_BIFTYPES)/BIFTYPE)"/>

<xsl:variable name="G_IFTYPES">
    <IFTYPE TYPE="SLAVE"/>
    <IFTYPE TYPE="MASTER"/>
    <IFTYPE TYPE="MASTER_SLAVE"/>
    
    <IFTYPE TYPE="TARGET"/>
    <IFTYPE TYPE="INITIATOR"/>
    
    <IFTYPE TYPE="MONITOR"/>
    
    <IFTYPE TYPE="USER"/>
<!-- 
     <IFTYPE TYPE="TRANSPARENT"/>
--> 
</xsl:variable> 
<xsl:variable name="G_IFTYPES_NUMOF" select="count(exsl:node-set($G_IFTYPES)/IFTYPE)"/>

<xsl:variable name="G_BUSSTDS">
	
	<BUSSTD NAME="AXI"/>
	<BUSSTD NAME="XIL"/>
	<BUSSTD NAME="OCM"/>
	<BUSSTD NAME="OPB"/>
	<BUSSTD NAME="LMB"/>
	<BUSSTD NAME="FSL"/>
	<BUSSTD NAME="DCR"/>
	<BUSSTD NAME="FCB"/>
	<BUSSTD NAME="PLB"/>
	<BUSSTD NAME="PLB34"/>
	<BUSSTD NAME="PLBV46"/>
	<BUSSTD NAME="PLBV46_P2P"/>
	
	<BUSSTD NAME="USER"/>
	<BUSSTD NAME="KEY"/>
</xsl:variable>
<xsl:variable name="G_BUSSTDS_NUMOF" select="count(exsl:node-set($G_BUSSTDS)/BUSSTD)"/>

</xsl:stylesheet>
