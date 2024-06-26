/*  Create the item created from a page */
%macro createItem(rc=);

        /*
         *   For each item that is to be saved, there should be the following routines:
         *    -  (optional) a getter, that will retrieve any existing metadata that may be required
         *       to have available when generating the AddMetadata Request.
         *       The name of the file must be in the form &filesDir./portlet/create.<itemtype>.get.xslt
         *       NOTE: This file is optional and processing will continue if not found!
         *    -  a parameter handler (that looks at the incoming requests and prepares the "new" metadata format.
         *       NOTE: This is a .sas file that has data step code snippets in it.
         *       The name of the file must be in the form &stepsDir./portlet/create.<itemtype>.parameters.sas
         *    -  a processor (which generates the metadata create to save the metadata). 
         *       NOTE: This is an xslt file.
         *       The name of the file must be in the form &filesDir./portlet/create.<itemtype>.xslt
         *   If any of those are not found, then this item type is not supported to be edited.
         */


        %if ("%upcase(&type.)"="PSPORTLET") %then %do;
            %let searchType=&portletType.;
            %end;
        %else %do;
            %let searchType=&type.;
            %end;

        %let createItemGetter=&filesDir./portlet/create.%lowcase(&searchType.).get.xslt;

        %let createItemParameterHandler=&stepsDir./portlet/create.%lowcase(&searchType.).parameters.sas;

        %let createItemProcessor=&filesDir./portlet/create.%lowcase(&searchType.).xslt;

        %let _ciRC=0;
        %let _ciRCMessage=;

        %if (
             (%sysfunc(fileexist(&createItemParameterHandler.))=0)
             or (%sysfunc(fileexist(&createItemProcessor.))=0)
             )
             %then %do;
                %let _ciRC=1;

                %let _ciRCMessage=One of the type handlers for type &type. is missing.;

                %issueMessage(messageKey=portletAddNotSupported);

             %end;
        %else %do;

            %getRepoInfo;

            filename newxml temp;

            filename addhndlr "&createItemParameterHandler.";

            /*
             * If we are going to get some metadata, create the response file
             * now so a reference is included in the parameter building.
             */
            %if (%sysfunc(fileexist(&createItemGetter.)) ne 0) %then %do;
                filename getrsp temp;
                %let metadataContext=%sysfunc(pathname(getrsp));
                %end;

            %buildModParameters(newxml,addhndlr,rc=_ciRC);

            filename addhndlr;

            %showFormattedXML(newxml,generated New Metadata xml);

            %if (&_ciRC. = 0) %then %do;

                /*
                 *  If this type has a getter, run it and upon successful
                 *  completion, merge it back into the new xml.
                 */

                %if (%sysfunc(fileexist(&createItemGetter.)) ne 0) %then %do;

                    /*
                     *  Generate the Get Metadata request
                     */

                    filename getreq temp;

                    filename getxsl "&createItemGetter.";

                    proc xsl in=newxml xsl=getxsl out=getreq;
                    run;

                    filename getxsl;

                    %showFormattedXML(getreq,Create Item getter generated metadata query);

                    /*
                     *  Issue the metadata request
                     */

                    proc metadata in=getreq out=getrsp;
                    run;

                    filename getreq;

                    %showFormattedXML(getrsp,Create Item getter metadata response);

                    %end;

                filename crtxsl "&createItemProcessor.";

                /*
                 *  Since some creation of objects may also need to update existing objects
                 *  we use an action=update (ie. check for UpdateMetadata) so that with one call
                 *  we can do both.
                 */
                %genModification(modxsl=crtxsl,newxml=newxml,action=update,rc=genCreateRC);

                %let _ciRC=&genCreateRC.;

                filename crtxsl;
                %end;
            %else %do;

                %issueMessage(messageKey=metadataGenerationFailed);

                %end;

            %if (%sysfunc(fileref(getrsp))<1) %then %do;
                filename getrsp;
                %end;

            filename newxml;

        %end;

     %if ("&rc." ne "" ) %then %do;
         %global &rc.;
         %let &rc.=&_ciRC.;
         %end;

%mend;
