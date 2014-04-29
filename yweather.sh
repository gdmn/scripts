#! /usr/bin/env bash

# by dmn

WOEID=526363

if [[ "$1" != "" ]]; then
	WOEID="$1"
fi

LOGFILE=`mktemp`
TRANSFORMATION=`mktemp`
wget  -q "http://weather.yahooapis.com/forecastrss?w=$WOEID&u=c" -O $LOGFILE || \
	wget "http://weather.yahooapis.com/forecastrss?w=$WOEID&u=c" -O - || \
	exit 1

# {{{ cat
cat >$TRANSFORMATION <<EOF
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:scripts="http://www.bluedust.com/sayweather"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:yweather="http://xml.weather.yahoo.com/ns/rss/1.0">

	<xsl:strip-space elements="*"/>
	<xsl:output method="text" encoding="utf-8" media-type="text/plain" indent="no"/>

	<xsl:template match="/">
		<xsl:apply-templates select="rss"/>
		<xsl:apply-templates select="channel"/>
	</xsl:template>

	<xsl:template match="channel">
		<xsl:value-of select="yweather:location/@city"/><xsl:text>, </xsl:text>
		<xsl:value-of select="yweather:location/@country"/>

		<xsl:text> (</xsl:text>
		<xsl:value-of select="yweather:astronomy/@sunrise"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="yweather:astronomy/@sunset"/>
		<xsl:text>)</xsl:text>

		<xsl:text></xsl:text>


		<xsl:apply-templates select="item"/>
	</xsl:template>

	<xsl:template match="item">
		<xsl:value-of select="yweather:condition/@temp"/>
		<xsl:value-of select="/rss/channel/yweather:units/@temperature"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="yweather:condition/@text"/>
		<xsl:text>, </xsl:text>
		
		<xsl:value-of select="/rss/channel/yweather:atmosphere/@pressure"/>
		<xsl:value-of select="/rss/channel/yweather:units/@pressure"/>
		<xsl:text> </xsl:text>
			<xsl:if test="/rss/channel/yweather:atmosphere/@rising = '0'">
			<xsl:text></xsl:text>
			</xsl:if>
			<xsl:if test="/rss/channel/yweather:atmosphere/@rising = '1'">
			<xsl:text>rising</xsl:text>
			</xsl:if>
			<xsl:if test="/rss/channel/yweather:atmosphere/@rising = '2'">
			<xsl:text>falling</xsl:text>
			</xsl:if>

		<xsl:text></xsl:text>

		<xsl:apply-templates select="yweather:forecast"/>
	</xsl:template>

	<xsl:template match="yweather:forecast">
		<xsl:value-of select="@day"/><xsl:text>: </xsl:text>
		<xsl:value-of select="@low"/>
		<xsl:value-of select="/rss/channel/yweather:units/@temperature"/>
		<xsl:text> / </xsl:text>
		<xsl:value-of select="@high"/>
		<xsl:value-of select="/rss/channel/yweather:units/@temperature"/>
		<xsl:text>, </xsl:text>
		<xsl:value-of select="@text"/>
		<xsl:text></xsl:text>
	</xsl:template>
	</xsl:stylesheet>

EOF
# }}}

xsltproc $TRANSFORMATION $LOGFILE

rm -f $LOGFILE
rm -f $TRANSFORMATION

