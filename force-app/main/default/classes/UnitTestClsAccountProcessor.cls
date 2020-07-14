@isTest
private class UnitTestClsAccountProcessor {
    /* old code */
    static Map<String, RecordType> mapRecordtypes = LibRecordTypeHelper.getRecordTypeForObjects(new Set<String> {'Case'});
    private static Account acc_au;
    private static Country__c c_au;
    private static String RESTAURANT_ID;
    private static Boolean IS_EXCEPTION;
    
    static final String testPostCode = 'Test_Scenario_PostCode';
	static final String testAdminArea = 'Test_Scenario_AdminArea';
	static final String testAdminAreaLabel = 'Test Scenario AdminArea';
	static final String testLocality = 'Test_Scenario_Locality';
	static final String testSubArea = 'Test_Scenario_SubArea';
	static final String testCountry = 'Test_Scenario_Country';
	static final String testCountryLabel = 'Test Scenario Country';
	static final String testDependentLocality = 'Test_Scenario_DependentLocality';
    static final xAL_Country__mdt country = [
	        SELECT DeveloperName, MasterLabel, Code__c
	        FROM xAL_Country__mdt
	        WHERE DeveloperName = :testCountry
	                                        ];

	static final xAL_AdministrativeArea__mdt area = [
	            SELECT DeveloperName, MasterLabel, Type__c, Code__c
	            FROM xAL_AdministrativeArea__mdt
	            WHERE DeveloperName = :testAdminArea
	        ];

	static final xAL_SubAdministrativeAreas__mdt subArea = [
	            SELECT DeveloperName, MasterLabel, Type__c, Code__c
	            FROM xAL_SubAdministrativeAreas__mdt
	            WHERE DeveloperName = :testSubArea
	        ];

	static final xAL_Locality__mdt locality = [
	            SELECT DeveloperName, MasterLabel, Type__c, Code__c
	            FROM xAL_Locality__mdt
	            WHERE DeveloperName = :testLocality
	        ];

	static final xAL_Locality__mdt dependentLocality = [
	            SELECT DeveloperName, MasterLabel, Type__c, Code__c
	            FROM xAL_Locality__mdt
	            WHERE DeveloperName = :testDependentLocality
	        ];

	static final xAL_PostalCode__mdt zipcode = [
	            SELECT DeveloperName, MasterLabel, Number__c
	            FROM xAL_PostalCode__mdt
	            WHERE DeveloperName = :testPostCode
	        ];
    
    static testMethod void testValidateAccountDeliveryService() {

        Country__c con = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert con;
        
        acc_au = new Account();
        acc_au = UnitTestDataFactory.createAccount('TestAccount1', con, 'FP_Account');
        acc_au.Delivery_Service__c = 'Unknown';
        acc_au.Phone='+85227367722';
        Test.startTest();
        insert acc_au;
        Test.stopTest();
        
        String actualVal = [SELECT Id, Delivery_Service__c FROM Account WHERE Id =: acc_au.Id].Delivery_Service__c;
        List<String> selectedValList = new List<String>(); 
        selectedValList = actualVal.split(';');
        System.assertEquals('Unknown', actualVal, 'Result is not as expected');
        System.assertEquals(1, selectedValList.size(), 'Expected siresult should be 1');
    }

    static void postSetup() {
        acc_au = [select Name,
                Record_Country__c,
                RecordtypeId,
                CurrencyIsoCode,
                Relay_Method__c from Account Where Recordtype.DeveloperName = 'DH_AU_Account' limit 1];

        c_au = [select Iso__c, Name, CurrencyIsoCode From Country__c Where Iso__c = 'AU' limit 1];
    }


    /* old code end*/

    /* test restrict city values */

    @testSetup
    static void setup() {
        UnitTestDataFactory.getRecordtypeValues();

        Integration_Config__c cs1 = new Integration_Config__c(
                Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0=');
        insert cs1;

        List<Platform_Country__c> platformCountry = new List<Platform_Country__c>();
        platformCountry.add(new Platform_Country__c(name = 'TalabatPlatform', country__c = 'Kuwait,Bahrain,Saudi Arabia,Oman,Qatar,United Arab Emirates'));
        platformCountry.add(new Platform_Country__c(name = 'FOCPlatform', country__c = 'Lebanon,Qatar,United Arab Emirates'));
        insert platformCountry;

        Country__c c = UnitTestDataFactory.createCountry('KR', 'Korea', 'KRW');
        c_au = UnitTestDataFactory.createCountry('AU', 'Australia', 'AUD');
        Company__c com = UnitTestDataFactory.createCompany('Yogiyo', 'Yogiyo', c);
        Company__c com_au = UnitTestDataFactory.createCompany('Delivery Hero Australia', 'DH_AU', c_au);
        insert new List<sObject> {c, c_au, com, com_au};

        acc_au = UnitTestDataFactory.createAccount('TestAccount', c_au, 'DH_AU_Account');
        insert new List<sObject> {acc_au};


        List<sObject> ls = Test.loadData(Business_Config__c.sObjectType, 'BusinessConfigData');

        Country__c it = UnitTestDataFactory.createCountry('IT', 'Italia', 'EUR');
        insert it;

        Account cdAccount = UnitTestDataFactory.createAccount('CD Account', it, 'CD_Account');
        cdAccount.BillingCity = 'Napoli';
        insert cdAccount;
        
        //Inserting addresses
        AddressDetail__c addr = new AddressDetail__c(

		    Type__c = 'Restaurant Address;Billing Address;Shipping Address',
		    Account__c = cdAccount.Id,
        	LatLng__Latitude__s = 10.0,
		    LatLng__Longitude__s = 5.0,

		    AddressLine__c = 'amazing add line....',

		    CountryDevName__c = country.DeveloperName,
		    CountryName__c = country.MasterLabel,
		    CountryCode__c = country.Code__c,

		    AdministrativeAreaDevName__c = area.DeveloperName,
		    AdministrativeAreaName__c = area.MasterLabel,
		    AdministrativeAreaCode__c = area.Code__c,
		    AdministrativeAreaType__c = area.Type__c,

		    SubAdministratriveAreaDevName__c = subArea.DeveloperName,
		    SubAdministrativeAreaName__c = subArea.MasterLabel,
		    SubAdministrativeAreaCode__c = subArea.Code__c,
		    SubAdministrativeAreaType__c = subArea.Type__c,

		    LocalityDevName__c = locality.DeveloperName,
		    LocalityName__c = locality.MasterLabel,
		    LocalityType__c = locality.Type__c,
		    LocalityCode__c = locality.Code__c,

		    DependentLocalityDevName_1__c = dependentLocality.DeveloperName,
		    DependentLocalityName_1__c = dependentLocality.MasterLabel,
		    DependentLocalityType_1__c = dependentLocality.Type__c,
		    DependentlocalityCode_1__c = dependentLocality.Code__c,

		    PostalCodeDevName__c = zipcode.DeveloperName,
		    PostalCodeName__c = zipcode.Number__c
		);

		insert addr;

        
        List<Business_Config__c> configs = new List<Business_Config__c>();

        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'RestrictBillingAndMailingCityValues',
                        'Process',
                        'checkBillingAndMailingCity',
                        'true',
                        it.id,
                        'CD_Account',
                        true,
                        true)
        );
        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'entityNameMap',
                        '{"United Arab Emirates":"Talabat Middle East Internet Services Co. L.L.C","Kuwait":"Talabat General Trading and Contractig Company W.L.L","Qatar":"Talabat QFC L.L.C;QFC License No. 00387","Bahrain":"Talabat Services Company S.P.C","Oman":"Talabat Electronic Services L.L.C","Kingdom of Saudi Arabia":"Talabat for Restaurants Company W.L.L","Jordan":"Food on clicK.com W.L.L"}',
                        it.id,
                        'CD_Account',
                        true,
                        true)
        );
        
        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'letterHeadAddressMap',
                        '{ "Hungary": "Cégnév: Delivery Hero Hungary Kft.;Székhely: 1093 Budapest, Czuczor u. 2. I. emelet;Postázási cím: 1243 Budapest, Pf. 655;Adószám: 11187433-2-43;Számlavezető bank: CIB Bank;Bankszámlaszám: 10700347-49372605-51100005;Képviselő: Kováts Dániel és Patai Zoltán ügyvezetők;Telefonszám: +36 1 / 3174170;E-mail: info@netpincer.hu" }',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );
        
        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'BankDetailsMap',
                    	'{"United Arab Emirates":"Talabat Middle East Internet Services Company L.L.C.;AE56 0330 0000 1912 0014 467;Mashreq Bank P.S.C.;0 1912 0014 467;BOMLAEADHDO","Kuwait":"Talabat General Trading and Contracting Company W.L.L.;KW24 NBOK 0000 0000 0000 1007 8160 55;National Bank of Kuwait;1007 8160 55;NBOKKWKW","Qatar":"Talabat Services Company W.L.L.;QA40 QNBA 0000 0000 0251 0283 8300 1;Qatar National Bank;0251 0283 8300 1;QNBAQAQA","Bahrain":"Talabat Services Company W.L.L;BH66 NBOB 0000 0099 6146 69;National Bank of Bahrain;99 6146 69;NBOBBHBM","Oman":"Talabat Electronic Services Company W.L.L.;0314-01978172-001-9;Bank Muscat Saog;0314-01978172-001-9;BMUSOMRXXXX","Kingdom of Saudi Arabia":"Talabat for Restaurants Company W.L.L.;SA77 4000 0000 0020 0701 2146;Samba Financial Group;20 0701 2146;SAMBSARI","Jordan":"Foodonclick.com - Jordan Private Shareholding Company;13011563431002;BANK OF JORDAN LTD;13011563431002;BJORJOAX"}',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );
        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'siteURLMap',
                    	'{"Argentina":"http://www.pedidosya.com.ar","Bolivia":"http://www.pedidosya.com.bo","Chile":"http://www.pedidosya.com.cl","Panamá":"https://www.appetito24.com.pa/","Paraguay":"http://www.pedidosya.com.py","Uruguay":"http://www.pedidosya.com.uy"}',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );

        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'generalConditionsURLMap',
                    	'{ "Chile":{  "Logistics":"https://www.pedidosya.cl/condiciones-generales-logistica",  "Marketing":"https://www.pedidosya.cl/condiciones-generales-marketplace"   },   "Bolivia":{        "Logistics":"https://www.pedidosya.com.bo/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.com.bo/condiciones-generales-marketplace"   },   "Panamá":{        "Logistics":"https://www.appetito24.com.pa/condiciones-generales-logistica",      "Marketing":"https://www.appetito24.com.pa/condiciones-generales-marketplace"   },   "Paraguay":{        "Logistics":"https://www.pedidosya.com.py/condiciones-generales-marketplace",    "Marketing":"https://www.pedidosya.com.py/condiciones-generales-marketplace"   },   "Uruguay":{        "Logistics":"https://www.pedidosya.com.uy/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.com.uy/condiciones-generales-marketplace"   },   "Argentina":{        "Logistics":"https://www.pedidosya.com.ar/condiciones-generales-logistica",      "Marketing":"https://www.pedidosya.com.ar/condiciones-generales-marketplace"   },   "Dominican Republic":{       "Logistics":"https://www.pedidosya.com.do/condiciones-generales-logistica",       "Marketing":"https://www.pedidosya.com.do/condiciones-generales-marketplace"     }}',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );

        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'pedidosyaTranslation',
                    	'{"Argentina":"PedidosYa","Bolivia":"PedidosYa","Chile":"PedidosYa","Panamá":"Appetito24","Paraguay":"PedidosYa","Uruguay":"PedidosYa"}',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );

        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'applicableLaw',
                    	'{"Argentina":"El Acuerdo se regirá por las leyes de la República Argentina, y cualquier disputa que pudiera originarse en virtud de las condiciones contenidas en las cláusulas que lo integran, se someterá a la jurisdicción de los Tribunales Ordinarios Nacionales en lo Comercial con sede en la Ciudad de Buenos Aires.","Bolivia":"Este Acuerdo será regido e interpretado de conformidad con las leyes del Estado Plurinacional de Bolivia.Toda y cualquier controversia o disputa que surja entre las Partes, en relación directa o indirecta con el presente Acuerdo, será resuelta definitivamente mediante arbitraje institucional en derecho, que será administrado por el Centro de Conciliación y Arbitraje Comercial de la Cámara de Industria, Comercio, Servicios y Turismo de Santa Cruz – CAINCO. El tribunal arbitral estará conformado por un (1) árbitro, el cual será elegido de acuerdo al Reglamento de Arbitraje del Centro señalado precedentemente. El arbitraje se desarrollará en idioma castellano, teniendo como sede la ciudad de Santa Cruz de la Sierra. La controversia será resuelta de acuerdo a la legislación sustantiva vigente en el Estado Plurinacional de Bolivia, la Ley No. 708, Ley de Conciliación y Arbitraje y el procedimiento aplicable será el previsto en el Reglamento de Arbitraje del Centro que administrará el arbitraje.","Chile":"Las Partes convienen que cualquier duda, dificultad o controversia que surja con motivo del presente Acuerdo o de sus documentos complementarios o modificatorios, ya sea que se refieran a su interpretación, eficacia, cumplimiento, validez, terminación o cualquier otra causa relacionada con este convenio, sea respecto de cualquiera de sus numerales o de todos ellos, se resolverá por un árbitro que tendrá el carácter de árbitro mixto, arbitrador en cuanto al procedimiento y de derecho en cuanto al fallo, conforme al Reglamento del Centro de Arbitrajes de la Cámara de Comercio de Santiago A.G. Los comparecientes confieren mandato especial irrevocable a la Cámara de Comercio de Santiago A.G. para que, a solicitud escrita de cualquiera de ellas, designe el árbitro mixto de entre los integrantes del Cuerpo Arbitral del Centro de Arbitrajes de esa Cámara, debiendo recaer el nombramiento en un abogado con a lo menos veinte años de ejercicio de la profesión. La sustitución o reemplazo del árbitro se hará conforme al procedimiento establecido para su nombramiento. En contra de las resoluciones del árbitro no procederá recurso alguno, salvo el de queja, por lo cual los comparecientes vienen en renunciar expresamente a ellos.El árbitro queda expresamente facultado para resolver todo asunto relacionado con su Competencia y/o Jurisdicción. Si antes de promoverse el arbitraje dejare de funcionar el Centro de Arbitraje de la Cámara de Comercio de Santiago AG., las Partes designarán de común acuerdo un árbitro con el mismo carácter. El árbitro fijará las reglas de procedimiento correspondiente. En caso de desacuerdo de las Partes en la designación del árbitro, éste será designado por el Juez de Letras de Turno en Lo Civil en Santiago, debiendo en este caso el árbitro ser o haber sido abogado integrante de la Corte Suprema o de la Corte de Apelaciones de Santiago. Si el árbitro designado por las Partes o por el Juez de Letras no pudiere o no quisiere aceptar el cargo o durante su desempeño cesare en el por cualquier causa, lo reemplazará o sucederá la o las personas designadas conforme al procedimiento anterior.","Panamá":"Este Acuerdo será regido e interpretado de conformidad con las leyes de la República de Panamá. Las Partes acuerdan que en caso de cualquier divergencia, controversia o disputa que se suscite entre ellas con relación a este Acuerdo se resolverá ante los Tribunales Ordinarios de la ciudad de Panamá.","Paraguay":"Este Acuerdo será regido e interpretado de conformidad con las leyes de la República de Paraguay. Las Partes acuerdan que en caso de cualquier divergencia, controversia o disputa que se suscite entre ellas con relación a este Acuerdo se resolverá ante los Tribunales Ordinarios de la Ciudad de Asunción.","Uruguay":"Este Acuerdo será regido e interpretado de conformidad con las leyes de la República Oriental del Uruguay.Las Partes acuerdan que en caso de cualquier divergencia, controversia o disputa que se suscite entre ellas con relación a este Acuerdo se resolverá ante los Tribunales Ordinarios de la Ciudad de Montevideo."}',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );

        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'Termination',
                    	'{"Argentina":"Asimismo, en caso de incumplimiento de una parte de cualquiera de las obligaciones asumidas en virtud del presente, la parte cumplidora podrá rescindir el Acuerdo, si subsistiera el incumplimiento luego de que la parte cumplidora hubiere intimado por medio fehaciente a subsanarlo en un plazo de 10 días hábiles. En dicho caso, este Acuerdo se resolverá de pleno derecho al vencimiento del plazo indicado, salvo que se opte por volver a exigir el cumplimiento.","Bolivia":"El incumplimiento de cualquiera de las Partes a cualquiera de las obligaciones establecidas en este Acuerdo y/o en la normativa aplicable, dará derecho a la Parta cumplidora a resolver el Acuerdo inmediatamente, sin perjuicio de poder reclamar los daños y perjuicios, de acuerdo con lo establecido en el artículo 569 del Código Civil, quedando el Acuerdo resuelto de pleno derecho y sin necesidad de intervención judicial alguna, bastando para tal efecto simplemente un aviso a la otra Parte en su domicilio, que la resolución del Acuerdo se ha hecho efectiva. Dicha diligencia se formalizará mediante Carta Notariada donde se detallará la causal que se aduce.","Chile":"Asimismo, en caso de incumplimiento de una parte de cualquiera de las obligaciones asumidas en virtud del presente, la parte cumplidora podrá rescindir el Acuerdo, si subsistiera el incumplimiento luego de que la parte cumplidora hubiere intimado por medio fehaciente a subsanarlo en un plazo de 10 días hábiles. En dicho caso, este Acuerdo se resolverá de pleno derecho al vencimiento del plazo indicado, salvo que se opte por volver a exigir el cumplimiento. ","Panamá":"Asimismo, en caso de incumplimiento de una parte de cualquiera de las obligaciones asumidas en virtud del presente, la parte cumplidora podrá rescindir el Acuerdo, si subsistiera el incumplimiento luego de que la parte cumplidora hubiere intimado por medio fehaciente a subsanarlo en un plazo de 10 días hábiles. En dicho caso, este Acuerdo se resolverá de pleno derecho al vencimiento del plazo indicado, salvo que se opte por volver a exigir el cumplimiento. ","Paraguay":"Asimismo, en caso de incumplimiento de una parte de cualquiera de las obligaciones asumidas en virtud del presente, la parte cumplidora podrá rescindir el Acuerdo, si subsistiera el incumplimiento luego de que la parte cumplidora hubiere intimado por medio fehaciente a subsanarlo en un plazo de 10 días hábiles. En dicho caso, este Acuerdo se resolverá de pleno derecho al vencimiento del plazo indicado, salvo que se opte por volver a exigir el cumplimiento. ","Uruguay":"Asimismo, en caso de incumplimiento de una parte de cualquiera de las obligaciones asumidas en virtud del presente, la parte cumplidora podrá rescindir el Acuerdo, si subsistiera el incumplimiento luego de que la parte cumplidora hubiere intimado por medio fehaciente a subsanarlo en un plazo de 10 días hábiles. En dicho caso, este Acuerdo se resolverá de pleno derecho al vencimiento del plazo indicado, salvo que se opte por volver a exigir el cumplimiento."}',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );

        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'fixedTerm',
                    	'{"Argentina":"Siempre que no se indique lo contrario en otro instrumento firmado por las Partes o en las Condiciones Particulares, cualquiera de ellas, podrá rescindir unilateralmente el servicio o ítem regulado, en cualquier momento. La Parte que desee hacer uso de la facultad indicada, deberá comunicarlo fehacientemente a la otra parte por lo menos 15 días antes de la fecha en que se desea rescindir. Esta terminación no generará indemnización alguna a favor de la otra parte. ","Bolivia":"Siempre que no se indique lo contrario en otro instrumento firmado por las Partes o en las Condiciones Particulares, cualquiera de ellas podrá rescindir unilateralmente el servicio o ítem regulado a su sola voluntad y discreción. Para estos efectos, bastará que la Parte que invoque la rescisión comunique por medio escrito con 15 días de anticipación a la fecha en la que se haga efectiva la terminación del presente Acuerdo, sin necesidad de detallar en su comunicación los motivos de su voluntad de rescindir. La rescisión unilateral del presente contrato no generará derecho a indemnización alguna a favor de la otra parte.","Chile":"Siempre que no se indique lo contrario en otro instrumento firmado por las Partes o en las Condiciones Particulares, cualquiera de ellas, podrá rescindir unilateralmente el servicio o ítem regulado, en cualquier momento. La Parte que desee hacer uso de la facultad indicada, deberá comunicarlo fehacientemente a la otra parte por lo menos 15 días antes de la fecha en que se desea rescindir. Esta terminación no generará indemnización alguna a favor de la otra parte.","Panamá":"Siempre que no se indique lo contrario en otro instrumento firmado por las Partes o en las Condiciones Particulares, cualquiera de ellas, podrá rescindir unilateralmente el servicio o ítem regulado, en cualquier momento. La Parte que desee hacer uso de la facultad indicada, deberá comunicarlo fehacientemente a la otra parte por lo menos 15 días antes de la fecha en que se desea rescindir. Esta terminación no generará indemnización alguna a favor de la otra parte.","Paraguay":"Siempre que no se indique lo contrario en otro instrumento firmado por las Partes o en las Condiciones Particulares, cualquiera de ellas, podrá rescindir unilateralmente el servicio o ítem regulado, en cualquier momento. La Parte que desee hacer uso de la facultad indicada, deberá comunicarlo fehacientemente a la otra parte por lo menos 15 días antes de la fecha en que se desea rescindir. Esta terminación no generará indemnización alguna a favor de la otra parte.","Uruguay":"Siempre que no se indique lo contrario en otro instrumento firmado por las Partes o en las Condiciones Particulares, cualquiera de ellas, podrá rescindir unilateralmente el servicio o ítem regulado, en cualquier momento. La Parte que desee hacer uso de la facultad indicada, deberá comunicarlo fehacientemente a la otra parte por lo menos 15 días antes de la fecha en que se desea rescindir. Esta terminación no generará indemnización alguna a favor de la otra parte."}',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );

        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'indeterminateTerm',
                    	'{"Argentina":"En caso de plazo indeterminado, cualquiera de las Partes podrá terminar unilateralmente el servicio o ítem regulado, en cualquier momento, comunicando su intención a la otra parte con al menos 15 días de antelación a la fecha deseada de terminación, sin que por esta terminación se genere indemnización alguna a favor de la otra parte.","Bolivia":"En caso de plazo indeterminado, cualquiera de las Partes podrá rescindir el servicio o ítem regulado con un preaviso por escrito de 15 días conforme lo establecido en el artículo 525 del Código Cvil de Bolivia, sin necesidad de expresión o manifestación del fundamento de su decisión. Esta rescisión unilateral no generará derecho a indemnización alguna a favor de la otra parte.","Chile":"En caso de plazo indeterminado, cualquiera de las Partes podrá terminar unilateralmente el servicio o ítem regulado, en cualquier momento, comunicando su intención a la otra parte con al menos 15 días de antelación a la fecha deseada de terminación, sin que por esta terminación se genere indemnización alguna a favor de la otra parte.","Panamá":"En caso de plazo indeterminado, cualquiera de las Partes podrá terminar unilateralmente el servicio o ítem regulado, en cualquier momento, comunicando su intención a la otra parte con al menos 15 días de antelación a la fecha deseada de terminación, sin que por esta terminación se genere indemnización alguna a favor de la otra parte.","Paraguay":"En caso de plazo indeterminado, cualquiera de las Partes podrá terminar unilateralmente el servicio o ítem regulado, en cualquier momento, comunicando su intención a la otra parte con al menos 15 días de antelación a la fecha deseada de terminación, sin que por esta terminación se genere indemnización alguna a favor de la otra parte.","Uruguay":"En caso de plazo indeterminado, cualquiera de las Partes podrá terminar unilateralmente el servicio o ítem regulado, en cualquier momento, comunicando su intención a la otra parte con al menos 15 días de antelación a la fecha deseada de terminación, sin que por esta terminación se genere indemnización alguna a favor de la otra parte."}',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );
        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'premPlacementProdName',
                    	'{"Premium Placement":"“Premium Placement” permite mejorar el posicionamiento del Cliente en el Portal. Por este sistema, la puntuación que tenga el Cliente en el Portal de acuerdo con la calificación que realicen los Usuarios se duplica, mejorando así su posicionamiento en búsquedas realizadas por Usuarios.","Premium Placement Gold":"“Premium Placement Gold” es un servicio de posicionamiento en el Portal que permite la presencia del Cliente en las tres primeras posiciones de la página de resultados del Portal en el barrio que se decide pautar. Existen solo tres espacios disponibles por barrio. Los barrios en los que se muestra un comercio tienen que ser parte de su zona de entrega. Solo se muestra el lugar destacado cuando el comercio está abierto y no se consideran prepedidos. Solo se mostrarán los comercios destacados a los Usuarios que estén geolocalizados dentro de uno de los barrios configurados como “Premium Placement Gold”.","Premium Placement Gold Category":"“Premium Placement Gold Category” es un servicio de posicionamiento en el Portal que permite que una categoría de productos que ofrece el Cliente tenga presencia en las tres primeras posiciones de la página de resultados del Portal en el barrio que se decide pautar. Existen solo tres espacios disponibles por barrio. Los barrios en los que se muestra un comercio tienen que ser parte de su zona de entrega. Solo se muestra el lugar destacado cuando el comercio está abierto y no se consideran prepedidos. Solo se mostrarán los comercios destacados a los Usuarios que estén geolocalizados dentro de uno de los barrios configurados como “Premium Placement Gold Category”."}',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );
        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'MjamQuoteLogoAddress',
                    	'Mjam GmbH<br/>Mayergasse 14/ 1+2<br/>A-1020 Wien<br/><br/>M &emsp; partner@mjam.net<br/>T &emsp; +43(0)800 100 33<br/>F &emsp; +43(0)1928 11 36',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );
        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'MjamMainQuoteAddress',
                    	'<b>Mjam GmbH</b> • Mayergasse 14/ 1+2  • A-1020 Wien • FN 309771 x Handelsgericht Wien • Geschäftsführer: Lars Niklas Östberg',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );
        configs.add(
                UnitTestDataFactory.createBusinessConfig(
                        'OppQuoteProcess',
                        'Process',
                        'MjamQuoteAddress',
                    	'Mjam GmbH/ Mayergasse 14/ 1+2/ A-1020 Wien',
                        it.id,
                        'CD_Account',
                        true,
                        false)
        );
       

        insert configs;

        BEIntegration_CountriesToCities__c cs = new BEIntegration_CountriesToCities__c(
                Name = 'Napoli', Country_Code__c = 'IT');
        insert cs;

        BEIntegration_CountriesToCities__c cs2 = new BEIntegration_CountriesToCities__c(
                Name = 'Roma', Country_Code__c = 'IT');
        insert cs2;

        // create custom settings
        CountryCompanyBrand__c ccb = new CountryCompanyBrand__c();
        ccb.name = 'Kuwait';
        ccb.code__c = 'KWTB';
        insert ccb;
        
        CountryCompanyBrand__c ccb2 = new CountryCompanyBrand__c();
        ccb2.name = 'United Kingdom';
        ccb2.code__c = 'UKHH';
        insert ccb2;

        // CREATE MIDAS CONF
        MidasIntegration__c conf = new MidasIntegration__c();
        conf.name = 'PP';
        conf.AuthenticationToken__c = '123';
        conf.EndPoint__c = 'https://www.eaxmple.com';
        conf.CountryBrand__c = '{"hungryhouse":"UKHH"}';
        insert conf;
        
    }

    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfBusinessConfigNotExists() {

        delete [select id from Business_Config__c];

        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.BillingCity = 'Not Exist';
        update acc;

        Test.stopTest();

    }

    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfBillingCityIsNotChanged() {
        Account acc = [Select BillingCity, Name From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.name = 'new name';
        update acc;

        Test.stopTest();
    }

    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfBillingCityIsBlank() {
        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.BillingCity = '';
        update acc;

        Test.stopTest();
    }

    @isTest static void checksBillingAndMailingCityValuesFilterCorrectlyByRecordType() {
        Country__c c = [select name, iso__c , currencyIsoCode from country__c where name = 'Italia' limit 1];

        Account a = UnitTestDataFactory.createAccount('Test', c, 'UK_Account');
        a.BillingCity = 'not exist';

        Test.startTest();

        insert a;

        Test.stopTest();
    }

    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfRuleIsNotActive() {
        Business_Config__c rule = [Select Business_Rule_Value__c From Business_Config__c Where Process_Name__c = 'RestrictBillingAndMailingCityValues' limit 1];
        rule.Business_Rule_Value__c = 'false';
        update rule;

        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.BillingCity = 'not exist';
        update acc;

        Test.stopTest();
    }


    @isTest static void checksBillingAndMailingCityValuesDoesNothingIfCityIsValid() {
        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        Test.startTest();

        acc.BillingCity = 'Roma';

        Test.stopTest();
    }


    @isTest static void checksBillingAndMailingCityValuesAddErrorToRecordIfCityIsNotValid() {
        Account acc = [Select BillingCity From Account where RecordType.DeveloperName = 'CD_Account' limit 1];

        DataBase.SaveResult res;

        Test.startTest();

        acc.BillingCity = 'notexist';

        res = Database.update(acc, false);

        Test.stopTest();

        System.assert(!res.isSuccess());
    }

    @isTest static void verifyGRIDRejectRecordsWithInvalidGRID() {
        Account acc =  [SELECT GRID__c, GRIDSequence__c FROM Account LIMIT 1];
        acc.GRID__c = UtilsGlobalIdentifier.getGlobalIdentifierFromSequenceNumber(Integer.valueOf(acc.GRIDSequence__c));
        update acc;

        Boolean thrown = false;

        Test.startTest();

        try {
            acc.GRID__c = acc.GRID__c + 'A';
            update acc;
        } catch (DmlException ex) {
            thrown = true;
        }

        Test.stopTest();

        System.assert(thrown);
    }

    @isTest static void testOwnershipChange(){
        IS_EXCEPTION = false;
        Country__c c = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'EUR');
        Company__c com = UnitTestDataFactory.createCompany('Hungryhouse', 'Hungryhouse', c);
        insert new List<sObject> {c,com};

        Account ukAcc 		= UnitTestDataFactory.createAccount('TestAccount', c, 'UK_Account');
        ukAcc.backend_id__c = '12345';
        insert ukAcc;
        RESTAURANT_ID = ukAcc.Id;
        // create another user
        User us = UnitTestDataFactory.createUser('System Administrator', 'test@deliveryhero.com','Hungryhouse', 'UK');
        insert us;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockMIDASOwnershipChange());
        ukAcc.ownerId = us.Id;
        update ukAcc;
        Test.stoptest();

        Account acct = [Select MIDASApiException__c from Account where id =: ukAcc.Id];
        System.assertEquals(null,acct.MIDASApiException__c);
    }

    @isTest static void testOwnershipChangeWithPlatform(){
        IS_EXCEPTION = false;
        Country__c c = UnitTestDataFactory.createCountry('UK', 'United Kingdom', 'EUR');
        Company__c com = UnitTestDataFactory.createCompany('Hungryhouse', 'Hungryhouse', c);
        insert new List<sObject> {c,com};

        Account ukAcc 		= UnitTestDataFactory.createAccount('TestAccount', c, 'UK_Account');
        ukAcc.backend_id__c = '12345';
        insert ukAcc;
        RESTAURANT_ID = ukAcc.Id;

        // create custom settings
        CountryCompanyBrand__c ccb = new CountryCompanyBrand__c();
        ccb.name = 'hungryhouse';
        ccb.code__c = 'UKHH';
        insert ccb;

        // Create platform
        Platform_Performance__c per = new Platform_performance__c();
        per.Account__c = ukAcc.Id;
        per.Platform__c = 'hungryhouse';
        per.backend_id__c = '123';
        insert per;

        // create another user
        User us = UnitTestDataFactory.createUser('System Administrator', 'test@deliveryhero.com','Hungryhouse', 'UK');
        insert us;

        Test.startTest();
        clsAccountHelper.populateCodeVsAccountsMap([select id,recordType.developerName,Record_Country__c, (select id,name,Platform__c from Platforms_performance__r )  from Account ] );
        Test.setMock(HttpCalloutMock.class, new MockMIDASOwnershipChange());
        ukAcc.ownerId = us.Id;
        update ukAcc;
        Test.stoptest();

        Account acct = [Select MIDASApiException__c from Account where id =: ukAcc.Id];
        System.assertEquals(null,acct.MIDASApiException__c);
    }

    @isTest static void testOwnershipException(){
        IS_EXCEPTION = true;
        Country__c c = UnitTestDataFactory.createCountry('KW', 'Kuwait', 'KWD');
        Company__c com = UnitTestDataFactory.createCompany('Talabat', 'talabat', c );
        insert new List<sObject> {c,com};

        Account ukAcc 		= UnitTestDataFactory.createAccount('TestAccount', c, 'Talabat_Account');
        ukAcc.backend_id__c = '12345';
        insert ukAcc;

        RESTAURANT_ID = ukAcc.Id;
        // create another user
        User us = UnitTestDataFactory.createUser('System Administrator', 'test@deliveryhero.com','Talabat', 'BH');
        insert us;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockMIDASOwnershipChange());

        ukAcc.ownerId = us.Id;
        update ukAcc;
        Test.stoptest();

        Account acct = [Select MIDASApiException__c from Account where id =: ukAcc.Id];
        System.assertNotEquals(null,acct.MIDASApiException__c);
    }

    /**
     * @description Test in the account country is populated correctly on related records
     */
    @IsTest
    public static void test_populateRelatedCountry() {
        Country__c c = UnitTestDataFactory.createCountry('UY', 'Uruguay', 'KWD');
        Country__c c2 = UnitTestDataFactory.createCountry('CL', 'Chile', 'KWD');
        insert new List<Country__c> {c, c2};
        Company__c com = UnitTestDataFactory.createCompany('PY', 'PY', c );
        Company__c com2 = UnitTestDataFactory.createCompany('PY', 'PY', c2 );
        insert new List<Company__c>{com, com2};
        Account pyAccount  = UnitTestDataFactory.createAccount('TestAccount', c, 'PY_Account');
        pyAccount.Record_Country__c = 'Uruguay';
        insert pyAccount;
        List<Opportunity> oppList = UnitTestDataFactory.createOpportunities(new List<Account>{pyAccount}, 1, 'Yogiyo_Opportunity', Date.today());
        insert oppList;
        List<Stock_Item__c> stockItems = UnitTestDataFactory.createStockItems(4, 'Yogiyo_Stock_Item', pyAccount, null, 'A1 - New used', Date.today(), Date.today().addDays(10), Date.today().addDays(-30), '1234567890', '1234567890', 'Korea Telekom', 'In Stock', 'Other');
        insert stockItems;
        Branding_Content__c bContent = new Branding_Content__c(Restaurant_Name__c = pyAccount.Id, Opportunity__c = oppList[0].Id);
        insert bContent;
        List<Asset__c> assets = UnitTestDataFactory.createAssets(10, pyAccount, oppList[0], Date.today().addDays(-10), true, stockItems[0], stockItems[1], 'PY_Asset', '12345674',
                '1', '1', Date.today(), Date.today(), 'En Route', true, 'Exchanged', 'Shared Information', 'Take over Information', 'Exchange Requested',
                Date.today().addDays(20), 'Yazi Logistics', '1234', 'none');
        insert assets;
        bContent = BrandingContent_Selector.findByAccountIds(new Set<Id> {pyAccount.Id})[0];
        assets = AssetSelector.findActiveByAccountIds(new Set<Id> {pyAccount.Id});

        System.assertEquals('Uruguay', bContent.Account_Country__c);
        for (Asset__c asset: assets) {
            System.assertEquals('Uruguay', asset.Account_Country__c);
        }
        pyAccount.Record_Country__c = 'Chile';
        update pyAccount;

        bContent = BrandingContent_Selector.findByAccountIds(new Set<Id> {pyAccount.Id})[0];
        assets = AssetSelector.findActiveByAccountIds(new Set<Id> {pyAccount.Id});

        System.assertEquals('Chile', bContent.Account_Country__c);
        for (Asset__c asset: assets) {
            System.assertEquals('Chile', asset.Account_Country__c);
        }

    }

    public class MockMIDASOwnershipChange implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            system.debug('MockMIDASOwnershipChange-->');
            res.setHeader('Content-Type', 'application/json');
            if(IS_EXCEPTION){
                res.setBody('{"data":{"results":[{"status":"ERROR","status_code":404,"description":"The restaurant was not found","ownership":{"username":"taha.holawala@deliveryhero.com","sf_restaurant_id":"'+ RESTAURANT_ID+'"}}]}}');
            }else{
                res.setBody('{"data":{"results":[{"status":"OK","ownership":{"username":"taha.holawala@deliveryhero.com","restaurant_id":27557,"sf_restaurant_id":"'+ RESTAURANT_ID+'"}}]}}');
            }
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testVerifyFPCategoryOneCat(){

        Country__c country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert country;
        Account acc = UnitTestDataFactory.createAccount('Test FP Account', country, 'FP_Account');
        acc.Phone = '+85227367722';
        acc.Vertical__c = 'Restaurant';
        acc.Vertical_Segment__c	= 'Regular Restaurant';
        acc.Category__c = 'American';
        Test.startTest();
            insert acc;
        Test.stopTest();
        List<Account> lstAfterInsert = [SELECT Id FROM Account WHERE Name = 'Test FP Account'];
        System.assertEquals(1, lstAfterInsert.size());
    }

    @isTest
    static void testVerifyFPCategoryTwoCat(){
        String errorMessage = '';

        Country__c country = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        insert country;
        Account acc = UnitTestDataFactory.createAccount('Test FP Account', country, 'FP_Account');
        acc.Phone = '+85227367722';
        acc.Vertical__c = 'Restaurant';
        acc.Vertical_Segment__c	= 'Regular Restaurant';
        acc.Category__c = 'African';    
        Test.startTest();
            try{
                insert acc;
            }catch(DmlException e){
                errorMessage = e.getDMLMessage(0);
            }
        Test.stopTest();

        System.assertEquals('bad value for restricted picklist field: African', errorMessage);
    }

    /**@date         : [30/03/2020]
    * @method name  : testUpdateFacilityDetails
    * @description  : Test method to insert the account of type Facility and Branch Kitchen Restaurant
    ********************************************************************
    * @param       : Void
    */
    @isTest
    static void testUpdateFacilityDetails(){
        Country__c country = UnitTestDataFactory.createCountry('KW', 'Kuwait', 'KWD');
        Account facilityAccount = UnitTestDataFactory.createAccount('Test Facility Account', country, 'Facility_Account');
        Account branchKitchenAccount = UnitTestDataFactory.createAccount('Test Branch Account', country, 'Talabat_Account');
        facilityAccount.Type = 'Facility';
        Test.startTest();
        insert facilityAccount;
        branchKitchenAccount.Facility__c  = facilityAccount.Id;
        branchKitchenAccount.Type = 'Branch - Kitchen Restaurant';
        insert branchKitchenAccount;

        branchKitchenAccount.Account_Status__c =  'Active';
        update branchKitchenAccount;

        Test.stopTest();
        System.assertEquals(branchKitchenAccount.Facility__c,facilityAccount.Id);
    }

    /**@date         : [30/03/2020]
    * @method name  : testCopyFacilityAddressToKitchen
    * @description  : Test method to copy the facility address when it is getting associated with Kitchen
    ********************************************************************
    * @param       : Void
    */
    @isTest
    static void testCopyFacilityAddressToKitchen(){
        UnitTestDataFactory.getRecordtypeValues();

        Country__c hk = UnitTestDataFactory.createCountry('HK', 'Hong Kong', 'HKD');
        Database.insert(hk);
        Company__c com = UnitTestDataFactory.createCompany('Foodpanda Hong Kong', 'FP', hk);
        insert com;

        // CREATE ACCOUNT
        Account accTemp;
        List<Account> accountList = new List<Account>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for(Integer counter = 0; counter < 2; counter++){
            accTemp = UnitTestDataFactory.createAccount('Test FP ' + (counter + 1), hk, 'Facility_Account');
            accTemp.Type = 'Facility';
            accountList.add(accTemp);
        }
        insert accountList;
        accountMap.putAll(accountList);

        //CREATE CONTACT
        List<Contact> conList = UnitTestDataFactory.createContacts(accountList, 'FP Contact', 'Test', '', 'Owner', 1, 'testFPContact', 'FP_Contact');
        conList[0].Contact_Role__c = 'Manager';
        conList[1].FirstName = null;
        conList[1].Phone = null;
        conList[1].Email = null;
        insert conList;

        //CREATE ADDRESS DETAILS
        Integration_Config__c cs1 = new Integration_Config__c(
                Name = 'GoogleMapsSignature', Password__c = 'Abvcd-asdfdgfhjklhnO0='
        );
        insert cs1;
        AddressDetail__c addDetail = new AddressDetail__c(

                Type__c = 'Restaurant Address;Billing Address',
                Account__c = accountList[0].Id,

                LatLng__Latitude__s = 10.0,
                LatLng__Longitude__s = 5.0,

                AddressLine__c = 'amazing add line....'
        );
        insert addDetail;
        Test.startTest();
        Account acc     = UnitTestDataFactory.createAccount('TestAccount1', hk, 'FP_Account');
        acc.Phone = '+85227367722';
        acc.Type ='Branch - Main';
        acc.Facility__c = accountList[0].id;
        insert acc;

        acc.Facility__c = accountList[1].id;
        update acc;

        Test.stopTest();
        System.assertEquals(accountList[1].id,acc.Facility__c);
    }

    /**
   * @date     : [20/05/2020]
   * @method name  : testUpdateChildAccounts
   * @description  : Test method for updateChildAccounts(SSC-1990)
   */
    @IsTest
    public static void testUpdateChildAccounts() {
        List<Account> brandAccounts = new List<Account>();
        List<Account> branchAccounts  = new List<Account>();

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Talabat_Account').getRecordTypeId();
        Account groupAccount = new Account(RecordTypeId = recordTypeId, Name = 'Group Account', Type = Constants.ACCOUNT_TYPE_GROUP);
        insert groupAccount;

        for(Integer brandInstance=0;brandInstance<10;brandInstance++){
            brandAccounts.add(new Account(RecordTypeId = recordTypeId, Name = 'Brand Account'+brandInstance, Type = Constants.ACCOUNT_TYPE_BRAND, ParentId = groupAccount.Id));
        }
        insert brandAccounts;

        for(Integer brandInstance=0;brandInstance<brandAccounts.size();brandInstance++){
            for(Integer branchInstance=0;branchInstance<25;branchInstance++){
                branchAccounts.add(new Account(RecordTypeId = recordTypeId, Name = 'Branch Account' + branchInstance, Type = Constants.ACCOUNT_TYPE_BRANCH_MAIN, ParentId = brandAccounts[brandInstance].Id));
            }
        }
        insert branchAccounts;

        Test.startTest();
        groupAccount.Key_VIP_Account__c = true;
        update groupAccount;
        System.assertEquals(groupAccount.Key_VIP_Account__c,true);
        Test.stopTest();
    }
}
