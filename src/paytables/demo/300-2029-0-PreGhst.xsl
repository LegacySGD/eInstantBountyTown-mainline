<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson retrievePrizeTable">
				<lxslt:script lang="javascript">
					<![CDATA[
					var debugFlag = false;
					var debugFeed = [];
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param
					function formatJson(jsonContext, translations, prizeTable, convertedPrizeValues, prizeNames)
					{
						var scenario = getScenario(jsonContext);
						var nameAndCollectList = (prizeNames.substring(1)).split(",");
						var prizeValues = (convertedPrizeValues.substring(1)).split('|');
						var stage1Collections = ["W", "I"];
						
						var stage1 = scenario.split('|')[0].split(',');
						var gangSets = scenario.split('|')[1].split(',');
						var stage2 = scenario.split('|')[2].split(',');

						var prizeNamesList = [];						
						for(var i = 0; i < nameAndCollectList.length; ++i)
						{
							var desc = nameAndCollectList[i];
							prizeNamesList.push(desc[desc.length - 1]);
						}
						
						registerDebugText("Prize Names: " + prizeNamesList);
						registerDebugText("Prize Values: " + prizeValues);
						registerDebugText("Scenario: " + scenario);
						registerDebugText("Stage 1: " + stage1);
						registerDebugText("Gang Sets: " + gangSets);
						registerDebugText("Stage 2: " + stage2);
					
						// Output winning numbers table.
						var r = [];

						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						// Stage 1
						////////////////////////////////////////////////////						
						r.push('<tr>');
						r.push('<td>');
						r.push(getTranslationByName("stage", translations) + " 1");
						r.push('</td>');
						
						// Headers
						r.push('<tr>');
						r.push('<td class="tablehead" width="50%">');
						r.push(getTranslationByName("poster", translations));
						r.push('</td>');
						
						r.push('<td class="tablehead" width="50%">');
						r.push(getTranslationByName("numCollected", translations));
						r.push('</td>');
						
						for(var collect = 0; collect < stage1Collections.length; ++collect)
						{
							r.push('<tr>');
							r.push('<td class="tablebody">');
							r.push(getTranslationByName(stage1Collections[collect], translations));
							r.push('</td>');
							
							r.push('<td class="tablebody">');
							r.push(countPrizeCollections(stage1Collections[collect], stage1));
							r.push('</td>');
							r.push('</tr>');
						}
						
						if((stage1.join()).indexOf("S") != -1)
						{
							// Handle Bonus Round
							// Headers
							r.push('<tr>');
							r.push('<td class="tablehead" width="50%">');
							r.push(getTranslationByName("bonus", translations));
							r.push('</td>');
							
							r.push('<td class="tablehead width="50%">');
							r.push(getTranslationByName("prize", translations));
							r.push('</td>');
							r.push('</tr>');
							
							r.push('<tr>');
							r.push('<td class="tablebody">');
							r.push(getTranslationByName("S", translations));
							r.push('</td>');
							
							// Check for Prize
							r.push('<td class="tablebody">');
							for(var i = 0; i < stage1.length; ++i)
							{
								var turn = stage1[i];
								if(turn[0] == "S")
								{								
									registerDebugText("Bonus Round: " + turn);
									registerDebugText("Bonus Type: " + turn[1]);
									if(turn[1] != "X")
									{
										r.push(prizeValues[prizeNamesList.indexOf(turn[1])]);
										registerDebugText("Bonus Value: " + prizeValues[prizeNamesList.indexOf(turn[1])]);
									}
									
									break;
								}							
							}
							r.push('</td>');
							r.push('</tr>');
						}


						r.push('</table>');
						
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						// Stage 2
						////////////////////////////////////////////////////						
						r.push('<tr>');
						r.push('<td>');
						r.push(getTranslationByName("stage", translations) + " 2");
						r.push('</td>');
						
						// Headers
						r.push('<tr>');
						r.push('<td class="tablehead" width="35%">');
						r.push(getTranslationByName("gangs", translations));
						r.push('</td>');
						
						r.push('<td class="tablehead" width="30%">');
						r.push(getTranslationByName("numCollected", translations));
						r.push('</td>');
						
						r.push('<td class="tablehead" width="35%">');
						r.push(getTranslationByName("prize", translations));
						r.push('</td>');
						r.push('</tr>');

                        var gangTotals = [4,4,3,3,2,2];                        
                        // Gang Collections
                        for(var gang = 0; gang < gangSets.length; ++gang)
                        {
                            r.push('<tr>');
						    r.push('<td class="tablebody">');
						    r.push(getTranslationByName("gang", translations) + " " + (gang + 1));
                            r.push('</td>');

                            var gangCount = 0;
                            r.push('<td class="tablebody">');
                            for(var pick = 0; pick < stage2.length; ++pick)
                            {                                
                                if(stage2[pick][0] == "W" && gangSets[gang].indexOf(stage2[pick][1]) != -1)
                                {
						            gangCount++;
                                }                                
                            }
                            r.push(gangCount + "/" + gangTotals[gang])
                            r.push('</td>');
                            
                            r.push('<td class="tablebody">');
                            if(gangCount == gangTotals[gang])
                            {
                                r.push(prizeValues[gang]);
                            }
                            r.push('</td>');
                            r.push('</tr>');
                        }                       

                        // Innocent Collections				
						r.push('<tr>');
                        r.push('<td class="tablebody">');
                        r.push(getTranslationByName("innocent", translations));
                        r.push('</td>');

                        var innocentCount = 0;
                        r.push('<td class="tablebody">');
                        for(var pick = 0; pick < stage2.length; ++pick)
                        {                             
                            if(stage2[pick][0] == "I")
                            {
                                innocentCount++;
                            }            
                        }
                        r.push(innocentCount);
                        r.push('</td>');
                        
                        r.push('<td class="tablebody"/>');                        
                        r.push('</tr>');
												
						r.push('</table>');
						
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
							{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
								r.push('</td>');
								r.push('</tr>');
							}
							r.push('</table>');
						}

						return r.join('');
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["23", "9", "31"]
					function getWinningNumbers(scenario)
					{
						var numsData = scenario.split("|")[0];
						return numsData.split(",");
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["8", "35", "4", "13", ...] or ["E", "E", "D", "G", ...]
					function getOutcomeData(scenario, index)
					{
						var outcomeData = scenario.split("|")[1];
						var outcomePairs = outcomeData.split(",");
						var result = [];
						for(var i = 0; i < outcomePairs.length; ++i)
						{
							result.push(outcomePairs[i].split(":")[index]);
						}
						return result;
					}
					
					// Input: List of winning numbers and the number to check
					// Output: true is number is contained within winning numbers or false if not
					function checkMatch(winningNums, boardNum)
					{
						for(var i = 0; i < winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum)
							{
								return true;
							}
						}
						
						return false;
					}
					
					function countPrizeCollections(prizeName, scenario)
					{
						registerDebugText("Checking for prize in scenario: " + prizeName);
						var count = 0;
						for(var char = 0; char < scenario.length; ++char)
						{
							if(prizeName == scenario[char])
							{
								count++;
							}
						}
						
						return count;
					}
					
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeTables, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeTableStrings = prizeTables.split("|");
						
						
						for(var i = 0; i < pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeTableStrings[i];
							}
						}
						
						return "";
					}
					
					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.getAttribute("key") == keyName)
							{
								return childNode.getAttribute("value");
							}
							
							index += 2;
						}
					}
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Wager.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<x:variable name="convertedPrizeValues">

					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>
				
				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
