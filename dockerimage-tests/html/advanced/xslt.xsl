<?xml version="1.0"?>

<!-- Copyright 2018 Akamai Technologies, Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.

You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:akamai="http://www.akamai.com/xslt/1.0"
        version="1.0"
        exclude-result-prefixes="akamai">

  <xsl:output method="html"/>

  <xsl:template match="/">
    <html>
      <body>

        <!--    HTTP VARIABLES   -->

        <xsl:if test="function-available('akamai:http')">
          <h3> HTTP variables </h3>
          <table>
            <tr>
              <td> Request Path </td>
              <td>REQUEST_PATH: <xsl:value-of select="akamai:http('REQUEST_PATH')"/> </td>
            </tr>
            <tr>
              <td> Request Method </td>
              <td>REQUEST_METHOD: <xsl:value-of select="akamai:http('REQUEST_METHOD')"/> </td>
            </tr>
            <tr>
              <td> Query String </td>
              <td>QUERY_STRING: <xsl:value-of select="akamai:http('QUERY_STRING')"/> </td>
            </tr>
            <tr>
              <td> Cookie string </td>
              <td>HTTP_COOKIE: <xsl:value-of select="akamai:http('HTTP_COOKIE')"/> </td>
            </tr>
            <tr>
              <td> User agent string </td>
              <td>HTTP_USER_AGENT: <xsl:value-of select="akamai:http('HTTP_USER_AGENT')"/> </td>
            </tr>
          </table>
        </xsl:if>

        <!--   EDGESCAPE VARIABLES  -->

        <xsl:if test="function-available('akamai:geo')">
          <h3> Edgescape variables </h3>
          <table>
            <tr>
              <td> Geo string </td>
              <td>geo(): <xsl:value-of select="akamai:geo()"/> </td>
            </tr>
            <tr>
              <td> Country code </td>
              <td>geo('country_code'): <xsl:value-of select="akamai:geo('country_code')"/> </td>
            </tr>
            <tr>
              <td> Location </td>
              <td>geo('city'): <xsl:value-of select="akamai:geo('city')"/> <xsl:text>, </xsl:text>
                geo('region_code'): <xsl:value-of select="akamai:geo('region_code')"/>
              </td>
            </tr>
          </table>
        </xsl:if>


        <!--   Cookie   -->

        <xsl:if test="function-available('akamai:cookie')">
          <h3> Cookie strings </h3>
          <table>
            <tr>
              <td> Cookie string(full) </td>
              <td>cookie(): <xsl:value-of select="akamai:cookie()"/> </td>
            </tr>
            <tr>
              <td> Cookie string(name) </td>
              <td>cookie('name'): <xsl:value-of select="akamai:cookie('name')"/> </td>
            </tr>
            <tr>
              <td> Cookie string(age) </td>
              <td>cookie('age'): <xsl:value-of select="akamai:cookie('age')"/> </td>
            </tr>
          </table>
        </xsl:if>

        <!--   Query String   -->

        <xsl:if test="function-available('akamai:query-string')">
          <h3> Query string strings </h3>
          <table>
            <tr>
              <td> Query string </td>
              <td>query-string(): <xsl:value-of select="akamai:query-string()"/> </td>
            </tr>
            <tr>
              <td> Query string(a) </td>
              <td>query-string('a'): <xsl:value-of select="akamai:query-string('a')"/> </td>
            </tr>
            <tr>
              <td> Query string(b) </td>
              <td>akamai:query-string('b'): <xsl:value-of select="akamai:query-string('b')"/> </td>
            </tr>
          </table>
        </xsl:if>

        <!--  User Agent   -->

        <xsl:if test="function-available('akamai:user-agent')">
          <h3> UserAgent </h3>
          <table>
            <tr>
              <td> User Agent - full </td>
              <td>user-agent(): <xsl:value-of select="akamai:user-agent()"/> </td>
            </tr>
            <tr>
              <td> User Agent (browser) </td>
              <td>user-agent('browser'): <xsl:value-of select="akamai:user-agent('browser')"/> </td>
            </tr>
            <tr>
              <td> User Agent (version) </td>
              <td>user-agent('version'): <xsl:value-of select="akamai:user-agent('version')"/> </td>
            </tr>
            <tr>
              <td> User Agent (os) </td>
              <td>user-agent('os'): <xsl:value-of select="akamai:user-agent('os')"/> </td>
            </tr>

          </table>
        </xsl:if>

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
