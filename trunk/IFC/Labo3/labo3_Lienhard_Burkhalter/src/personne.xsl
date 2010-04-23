<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:output 
		method="html" 
		encoding="UTF-8"
	/>

	<xsl:template match="/">
		<xsl:for-each select="liste/personne">
			<xsl:choose>
				<xsl:when test="telephone/mobile/indicatif &#61; 076">
					<span style="color:red;">
						Nom: <xsl:value-of select="nom" /> <BR/>
						Prenom: <xsl:value-of select="prenom" />
					</span>
				</xsl:when>
				<xsl:when test="telephone/mobile/indicatif &#61; 078">
					<span style="color:orange">
						Nom: <xsl:value-of select="nom" /> <BR/>
						Prenom: <xsl:value-of select="prenom" />
					</span>
				</xsl:when>
				<xsl:when test="telephone/mobile/indicatif &#61; 079">
					<span style="color:blue">
						Nom: <xsl:value-of select="nom" /> <BR/>
						Prenom: <xsl:value-of select="prenom" />
					</span>
				</xsl:when>
				
				<xsl:otherwise>
					<span style="color:black">
						Nom:<xsl:apply-templates select="nom" /><BR/>
						Prenom:<xsl:apply-templates select="prenom" />
					</span>
				</xsl:otherwise>
			</xsl:choose>
			<BR/>
		</xsl:for-each>
	</xsl:template>	
	
</xsl:stylesheet>
