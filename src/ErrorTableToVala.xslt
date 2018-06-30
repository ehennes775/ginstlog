<?xml version="1.0" encoding="UTF-8"?>
<!--
Converts the ErrorTable.xml file into Vala source code.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output indent="no"/>
    <xsl:output method="text"/>
    <xsl:output omit-xml-declaration="yes"/>
    <xsl:param name="path">/ErrorTable/ErrorDomain[@id='CommunicationError']</xsl:param>
    <xsl:template match="/ErrorTable/ErrorDomain">
        <xsl:text>/**&#x0A;</xsl:text>
        <xsl:text> *&#x0A;</xsl:text>
        <xsl:text> */&#x0A;</xsl:text>
        <xsl:text>namespace ginstlog&#x0A;</xsl:text>
        <xsl:text>{&#x0A;</xsl:text>
        <xsl:text>    public errordomain </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>&#x0A;</xsl:text>
        <xsl:text>    {&#x0A;</xsl:text>
        <xsl:for-each select="./Error">
            <xsl:text>        /**&#x0A;</xsl:text>
            <xsl:text>         * </xsl:text>
            <xsl:value-of select="Description"/>
            <xsl:text>&#x0A;</xsl:text>
            <xsl:text>         */&#x0A;</xsl:text>
            <xsl:text>        </xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>,&#x0A;</xsl:text>
            <xsl:text>&#x0A;</xsl:text>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:for-each>
        <xsl:text>    }&#x0A;</xsl:text>
        <xsl:text>}&#x0A;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
