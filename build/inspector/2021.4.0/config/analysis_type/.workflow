<?xml version="1.0" encoding="utf-8"?>

<bag
   xmlns:boolean="http://www.w3.org/2001/XMLSchema#boolean"
   xsl:version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" exsl:keep_exsl_namespace=""
>

    <workflow displayName="memory_errors.name">
        <description>memory_errors.description</description>
        <property name="analysis_image">memory-analysis</property>
                <hierarchy>
                    <item idToUse="mc1"/>
                    <item idToUse="mc2"/>
                    <item idToUse="mc3"/>
                </hierarchy>
    </workflow>


    <workflow displayName="threading_errors.name">
        <description>threading_errors.description</description>
        <property name="analysis_image">threading-analysis</property>
                <hierarchy>
                    <item idToUse="tc1"/>
                    <item idToUse="tc2"/>
                    <item idToUse="tc3"/>
                </hierarchy>
    </workflow>

    <workflow displayName="custom_analysis_types.name">
        <description>custom_analysis_types.description</description>
        <property name="analysis_image">custom-analysis</property>
        <hierarchy>
            <userItems/>
        </hierarchy>
    </workflow>

    <defaultItem idToUse="mc2"/>
</bag>
