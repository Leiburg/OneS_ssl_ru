///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Процедура ПриПолученииПредставленияСертификата(Знач Сертификат, Знач ДобавкаВремени, Представление) Экспорт
	
	// Локализация
	ДатыСертификата = ЭлектроннаяПодписьСлужебныйКлиентСервер.ДатыСертификата(Сертификат, ДобавкаВремени);
	Представление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1, до %2'"),
		ПредставлениеСубъекта(Сертификат, Ложь), Формат(ДатыСертификата.ДатаОкончания, "ДФ=MM.yyyy"));
	// Конец Локализация
	
КонецПроцедуры

Процедура ПриПолученииПредставленияСубъекта(Знач Сертификат, Представление) Экспорт
	
	// Локализация
	Представление = ПредставлениеСубъекта(Сертификат, Истина);
	// Конец Локализация
	
КонецПроцедуры

Процедура ПриПолученииРасширенныхСвойствСубъектаСертификата(Знач Субъект, Свойства) Экспорт
	
	// Локализация
	Свойства = Новый Структура;
	Свойства.Вставить("ОГРН");
	Свойства.Вставить("ОГРНИП");
	Свойства.Вставить("СНИЛС");
	Свойства.Вставить("ИНН");
	Свойства.Вставить("Фамилия");
	Свойства.Вставить("Имя");
	Свойства.Вставить("Отчество");
	Свойства.Вставить("Должность");
	Свойства.Вставить("Организация");
	Свойства.Вставить("ОбщееИмя");
	Свойства.Вставить("ИННЮЛ");
	
	Если Субъект.Свойство("OGRN")Тогда
		Свойства.ОГРН = ПодготовитьСтроку(Субъект.OGRN);
		
	ИначеЕсли Субъект.Свойство("OID1_2_643_100_1") Тогда
		Свойства.ОГРН = ПодготовитьСтроку(Субъект.OID1_2_643_100_1);
	КонецЕсли;
	
	Если Субъект.Свойство("OGRNIP") Тогда
		Свойства.ОГРНИП = ПодготовитьСтроку(Субъект.OGRNIP);
		
	ИначеЕсли Субъект.Свойство("OID1_2_643_100_5") Тогда
		Свойства.ОГРНИП = ПодготовитьСтроку(Субъект.OID1_2_643_100_5);
	КонецЕсли;
	
	Если Субъект.Свойство("SNILS") Тогда
		Свойства.СНИЛС = ПодготовитьСтроку(Субъект.SNILS);
		
	ИначеЕсли Субъект.Свойство("OID1_2_643_100_3") Тогда
		Свойства.СНИЛС = ПодготовитьСтроку(Субъект.OID1_2_643_100_3);
	КонецЕсли;
	
	ЗаполнитьИНН(Свойства, Субъект);
	
	Если Субъект.Свойство("CN") Тогда
		Свойства.ОбщееИмя = ПодготовитьСтроку(Субъект.CN);
	КонецЕсли;
	
	Если Субъект.Свойство("O") Тогда
		Свойства.Организация = ПодготовитьСтроку(Субъект.O);
	КонецЕсли;
	
	Если Субъект.Свойство("SN") Тогда // Наличие фамилии (обычно для должностного лица).
		
		// Извлечение ФИО из поля SN и GN.
		Свойства.Фамилия = ПодготовитьСтроку(Субъект.SN);
		
		Если Субъект.Свойство("GN") Тогда
			Отчество = ПодготовитьСтроку(Субъект.GN);
			Позиция = СтрНайти(Отчество, " ");
			Если Позиция = 0 Тогда
				Свойства.Имя = Отчество;
			Иначе
				Свойства.Имя = Лев(Отчество, Позиция - 1);
				Свойства.Отчество = ПодготовитьСтроку(Сред(Отчество, Позиция + 1));
			КонецЕсли;
		КонецЕсли;
		
	ИначеЕсли ЗначениеЗаполнено(Свойства.ОГРНИП)    // Признак индивидуального предпринимателя.
	      Или Субъект.Свойство("T")                 // Признак должностного лица.
	      Или Субъект.Свойство("OID2_5_4_12")       // Признак должностного лица.
	      Или ЗначениеЗаполнено(Свойства.СНИЛС)     // Признак физического лица.
	      Или ЭтоИННФизЛица(Свойства.ИНН) И НЕ ЗначениеЗаполнено(Свойства.ИННЮЛ) Тогда // Признак физического лица.
		
		Если Свойства.ОбщееИмя <> Свойства.Организация
			   И Не (Субъект.Свойство("T")           И Свойства.ОбщееИмя = ПодготовитьСтроку(Субъект.T))
			   И Не (Субъект.Свойство("OID2_5_4_12") И Свойства.ОбщееИмя = ПодготовитьСтроку(Субъект.OID2_5_4_12)) Тогда
				
				// Извлечение ФИО из поля CN.
				Массив = СтрРазделить(Свойства.ОбщееИмя, " ", Ложь);
				
				Если Массив.Количество() < 4 Тогда
					Если Массив.Количество() > 0 Тогда
						Свойства.Фамилия = СокрЛП(Массив[0]);
					КонецЕсли;
					Если Массив.Количество() > 1 Тогда
						Свойства.Имя = СокрЛП(Массив[1]);
					КонецЕсли;
					Если Массив.Количество() > 2 Тогда
						Свойства.Отчество = СокрЛП(Массив[2]);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Свойства.Фамилия) Или ЗначениеЗаполнено(Свойства.Имя) Тогда
		Если Субъект.Свойство("T") Тогда
			Свойства.Должность = ПодготовитьСтроку(Субъект.T);
			
		ИначеЕсли Субъект.Свойство("OID2_5_4_12") Тогда
			Свойства.Должность = ПодготовитьСтроку(Субъект.OID2_5_4_12);
		КонецЕсли;
	КонецЕсли;
	
	// Конец Локализация
	
КонецПроцедуры

Процедура ПриПолученииРасширенныхСвойствИздателяСертификата(Знач Издатель, Свойства) Экспорт
	
	// Локализация
	Свойства = Новый Структура;
	Свойства.Вставить("ОГРН");
	Свойства.Вставить("ИНН");
	Свойства.Вставить("ИННЮЛ");
	
	Если Издатель.Свойство("OGRN") Тогда
		Свойства.ОГРН = ПодготовитьСтроку(Издатель.OGRN);
		
	ИначеЕсли Издатель.Свойство("OID1_2_643_100_1") Тогда
		Свойства.ОГРН = ПодготовитьСтроку(Издатель.OID1_2_643_100_1);
	КонецЕсли;
	
	ЗаполнитьИНН(Свойства, Издатель);
	// Конец Локализация
	
КонецПроцедуры

Процедура ПриПолученииКонвертаXML(Параметры, КонвертXML) Экспорт
	
	// Локализация
	Если Параметры.Вариант = КонвертПоУмолчанию() Тогда
		КонвертXML = КонвертXML1();
	ИначеЕсли Параметры.Вариант = "dmdk.goznak.ru_v1" Тогда
		КонвертXML = КонвертXML2();
	КонецЕсли;
	// Конец Локализация
	
КонецПроцедуры

Процедура ПриПолученииВариантаКонвертаПоУмолчанию(КонвертXML) Экспорт

	// Локализация
	КонвертXML = КонвертПоУмолчанию();
	// Конец Локализация
	
КонецПроцедуры

// Адрес списка отзыва, расположенного на другом ресурсе.
// 
// Параметры:
//  ИмяИздателя - Строка - имя издателя латиницей в нижнем регистре
//  Сертификат  - ДвоичныеДанные
//              - Строка
// 
// Возвращаемое значение:
//  Структура:
//   * АдресВнутренний - Строка - идентификатор для поиска в базе
//   * АдресВнешний - Строка - адрес ресурса для скачивания
//
Функция АдресСпискаОтзываВнутренний(ИмяИздателя, Сертификат) Экспорт
	
	Результат = Новый Структура("АдресВнешний, АдресВнутренний");
	
	// Локализация
	ИмяИздателя = СтрЗаменить(ИмяИздателя, " ", "_");
	ИмяИздателя = СокрЛП(СтрСоединить(СтрРазделить(ИмяИздателя, "!*'();:@&=+$,/?%#[]\|<>", Истина), ""));
	
	ИмяИздателя = ОбщегоНазначенияКлиентСервер.ЗаменитьНедопустимыеСимволыВИмениФайла(ИмяИздателя, "");
	
	Если Не ЗначениеЗаполнено(ИмяИздателя) Тогда
		Возврат Результат;
	КонецЕсли;
	
	Если ИмяИздателя <> "federalnaya_nalogovaya_sluzhba" Тогда
		Возврат Результат;
	КонецЕсли;
	
	ИдентификаторКлючаУдостоверяющегоЦентра = 
		ЭлектроннаяПодписьСлужебныйКлиентСервер.ИдентификаторКлючаУдостоверяющегоЦентра(Сертификат);
	
	Если Не ЗначениеЗаполнено(ИдентификаторКлючаУдостоверяющегоЦентра) Тогда
		Возврат Результат;
	КонецЕсли;
	
	Результат.АдресВнутренний = СтрШаблон("%1/%2", ИмяИздателя, НРег(ИдентификаторКлючаУдостоверяющегоЦентра));
	Результат.АдресВнешний = СтрШаблон("http://ca.1c.ru/crls/%1.zip", Результат.АдресВнутренний);
	// Конец локализация
	
	Возврат Результат;
	
КонецФункции

// Возвращаемое значение:
//  Неопределено, Структура - данные удостоверяющего центра:
//   * Государственный - Булево
//   * РазрешенныйНеаккредитованный - Булево
//   * ПериодыДействия - Неопределено, Массив из Структура:
//     **ДатаС - Дата
//     **ДатаПо - Дата, Неопределено
//   * ДатаОкончанияДействия - Неопределено, Дата
//   * ДатаОбновления  - Неопределено, Дата
//   * ДругиеНастройки - Соответствие
//
Функция ДанныеУдостоверяющегоЦентра(ЗначенияПоиска, АккредитованныеУдостоверяющиеЦентры) Экспорт
	
	Результат = Неопределено;
	
	// Локализация
	Если АккредитованныеУдостоверяющиеЦентры = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	НайденПериодДействия = Неопределено;
	НайденаДатаОкончанияДействия = Неопределено;
	МассивПолейПоиска = СтрРазделить(ЗначенияПоиска, ",");
	Государственный = Ложь;
	РазрешенныйНеаккредитованный = Ложь;
	
	Для Каждого ЗначениеПоиска Из МассивПолейПоиска Цикл
		
		ПодготовленноеЗначениеПоиска = ПодготовитьЗначениеПоиска(ЗначениеПоиска);
		
		Если НайденПериодДействия = Неопределено Тогда
			НайденПериодДействия = АккредитованныеУдостоверяющиеЦентры.ПериодыДействия.Получить(ПодготовленноеЗначениеПоиска);
		КонецЕсли;
		
		Если НайденаДатаОкончанияДействия = Неопределено Тогда
			НайденаДатаОкончанияДействия = АккредитованныеУдостоверяющиеЦентры.ДатыОкончанияДействия.Получить(ПодготовленноеЗначениеПоиска);
		КонецЕсли;
		
		Если Не Государственный И АккредитованныеУдостоверяющиеЦентры.ГосударственныеУЦ.Получить(ПодготовленноеЗначениеПоиска) <> Неопределено Тогда
			Государственный = Истина;
		КонецЕсли;
		
		Если Не РазрешенныйНеаккредитованный И АккредитованныеУдостоверяющиеЦентры.РазрешенныеНеаккредитованныеУЦ.Получить(ПодготовленноеЗначениеПоиска) <> Неопределено Тогда
			РазрешенныйНеаккредитованный = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	Если НайденПериодДействия = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Результат = Новый Структура;
	Результат.Вставить("Государственный",              Государственный);
	Результат.Вставить("РазрешенныйНеаккредитованный", РазрешенныйНеаккредитованный);
	Результат.Вставить("ПериодыДействия",       НайденПериодДействия);
	Результат.Вставить("ДатаОкончанияДействия", НайденаДатаОкончанияДействия);
	Результат.Вставить("ДатаОбновления",  АккредитованныеУдостоверяющиеЦентры.ДатаОбновления);
	Результат.Вставить("ДругиеНастройки", АккредитованныеУдостоверяющиеЦентры.ДругиеНастройки);
	
	// Конец Локализация
	
	Возврат Результат;
	
КонецФункции

Процедура ПриОпределенииСсылкиНаИнструкциюПоРаботеСПрограммами(Раздел, НавигационнаяСсылка) Экспорт
	
	// Локализация
	
	Если Раздел = "УчетВГосударственныхУчреждениях" Тогда
		НавигационнаяСсылка = "http://its.1c.ru/bmk/bud/digsig";
	Иначе
		НавигационнаяСсылка = "http://its.1c.ru/bmk/comm/digsig";
	КонецЕсли;
	
	// Конец Локализация
	
КонецПроцедуры

Процедура ПриОпределенииСсылкиНаИнструкциюПоТипичнымПроблемамПриРаботеСПрограммами(НавигационнаяСсылка, ИмяРаздела = "") Экспорт
	
	// Локализация
	
	НавигационнаяСсылка = "https://its.1c.ru/db/metod81#content:5784:hdoc"
		+ ?(ПустаяСтрока(ИмяРаздела), "", ":" + ИмяРаздела);
	
	// Конец Локализация
	
КонецПроцедуры

// Локализация

#Область ШаблоныКонвертаXML

Функция КонвертПоУмолчанию()
	
	Возврат "furs.mark.crpt.ru_v1";
	
КонецФункции

// Вариант "furs.mark.crpt.ru_v1".
Функция КонвертXML1()
	
	Возврат
	"<soap:Envelope
	|    xmlns:wsse=""http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd""
	|    xmlns:wsu=""http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd""
	|    xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
	|  <soap:Header>
	|    <wsse:Security soap:actor=""http://smev.gosuslugi.ru/actors/smev"">
	|      <ds:Signature xmlns:ds=""http://www.w3.org/2000/09/xmldsig#"">
	|        <SignedInfo xmlns=""http://www.w3.org/2000/09/xmldsig#"">
	|          <CanonicalizationMethod Algorithm=""http://www.w3.org/2001/10/xml-exc-c14n#""/>
	|          <SignatureMethod Algorithm=""%SignatureMethod%""/>
	|          <Reference URI=""#body"">
	|            <Transforms>
	|              <Transform Algorithm=""http://www.w3.org/2000/09/xmldsig#enveloped-signature""/>
	|              <Transform Algorithm=""http://www.w3.org/2001/10/xml-exc-c14n#""/>
	|            </Transforms>
	|            <DigestMethod Algorithm=""%DigestMethod%""/>
	|            <DigestValue>%DigestValue%</DigestValue>
	|          </Reference>
	|        </SignedInfo>
	|        <SignatureValue xmlns=""http://www.w3.org/2000/09/xmldsig#"">
	|          %SignatureValue%
	|        </SignatureValue>
	|        <ds:KeyInfo>
	|          <wsse:SecurityTokenReference>
	|            <wsse:Reference URI=""#SenderCertificate""
	|                            ValueType=""http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3""/>
	|          </wsse:SecurityTokenReference>
	|        </ds:KeyInfo>
	|      </ds:Signature>
	|      <wsse:BinarySecurityToken
	|              EncodingType=""http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary""
	|              ValueType=""http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3""
	|              wsu:Id=""SenderCertificate"">
	|        %BinarySecurityToken%
	|      </wsse:BinarySecurityToken>
	|    </wsse:Security>
	|  </soap:Header>
	|  <soap:Body wsu:Id=""body"">
	|    %MessageXML%
	|  </soap:Body>
	|</soap:Envelope>";
	
КонецФункции

// Вариант "dmdk.goznak.ru_v1".
Функция КонвертXML2()
	
	Возврат
	"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/""
	|    xmlns:ns=""urn://xsd.dmdk.goznak.ru/exchange/1.0""
	|    xmlns:ns1=""urn://xsd.dmdk.goznak.ru/batch/1.0""
	|    xmlns:ns2=""urn://xsd.dmdk.goznak.ru/contractor/1.0""
	|    xmlns:ns3=""urn://xsd.dmdk.goznak.ru/types/1.0"">
	|  <soapenv:Header />
	|  <soapenv:Body>
	|    <ns:CheckBatchRequest>
	|      <ns:CallerSignature>
	|        <ds:Signature xmlns:ds=""http://www.w3.org/2000/09/xmldsig#"">
	|          <ds:SignedInfo>
	|            <ds:CanonicalizationMethod Algorithm=""http://www.w3.org/2001/10/xml-exc-c14n#"" />
	|            <ds:SignatureMethod Algorithm=""%SignatureMethod%"" />
	|            <ds:Reference URI=""#body"">
	|              <ds:Transforms>
	|                <ds:Transform Algorithm=""http://www.w3.org/2001/10/xml-exc-c14n#"" />
	|                <ds:Transform Algorithm=""urn://smev-gov-ru/xmldsig/transform"" />
	|              </ds:Transforms>
	|              <ds:DigestMethod Algorithm=""%DigestMethod%"" />
	|              <ds:DigestValue>%DigestValue%</ds:DigestValue>
	|            </ds:Reference>
	|          </ds:SignedInfo>
	|          <ds:SignatureValue>%SignatureValue%</ds:SignatureValue>
	|          <ds:KeyInfo>
	|            <ds:X509Data>
	|              <ds:X509Certificate>%BinarySecurityToken%</ds:X509Certificate>
	|            </ds:X509Data>
	|          </ds:KeyInfo>
	|        </ds:Signature>
	|      </ns:CallerSignature>
	|      <ns:RequestData Id=""body"">
	|        %MessageXML%
	|      </ns:RequestData>
	|    </ns:CheckBatchRequest>
	|  </soapenv:Body>
	|</soapenv:Envelope>";
	
КонецФункции

#КонецОбласти

// Конец Локализация

// Локализация

Функция ПредставлениеСубъекта(Знач Сертификат, Знач Отчество) 
	
	Субъект = ЭлектроннаяПодписьСлужебныйКлиентСервер.СвойстваСубъектаСертификата(Сертификат);
	
	Если ЗначениеЗаполнено(Субъект.Фамилия)
	   И ЗначениеЗаполнено(Субъект.Имя) Тогда
		
		Представление = Субъект.Фамилия + " " + Субъект.Имя;
		
	ИначеЕсли ЗначениеЗаполнено(Субъект.Фамилия) Тогда
		Представление = Субъект.Фамилия;
		
	ИначеЕсли ЗначениеЗаполнено(Субъект.Имя) Тогда
		Представление = Субъект.Имя;
	КонецЕсли;
	
	Если Отчество И ЗначениеЗаполнено(Субъект.Отчество) Тогда
		Представление = Представление + " " + Субъект.Отчество;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Представление) Тогда
		Если ЗначениеЗаполнено(Субъект.Организация) Тогда
			Представление = Представление + ", " + Субъект.Организация;
		КонецЕсли;
		Если ЗначениеЗаполнено(Субъект.Подразделение) Тогда
			Представление = Представление + ", " + Субъект.Подразделение;
		КонецЕсли;
		Если ЗначениеЗаполнено(Субъект.Должность) Тогда
			Представление = Представление + ", " + Субъект.Должность;
		КонецЕсли;
		
	ИначеЕсли ЗначениеЗаполнено(Субъект.ОбщееИмя) Тогда
		Представление = Субъект.ОбщееИмя;
	КонецЕсли;
	Возврат Представление;
	
КонецФункции

Функция ПодготовитьСтроку(СтрокаИзСертификата)
	Возврат СокрЛП(ОбщегоНазначенияКлиентСервер.ЗаменитьНедопустимыеСимволыXML(СтрокаИзСертификата));
КонецФункции

Функция ЭтоИННФизЛица(ИНН)
	
	Если СтрДлина(ИНН) <> 12 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Для НомерСимвола = 1 По 12 Цикл
		Если СтрНайти("0123456789", Сред(ИНН,НомерСимвола,1)) = 0 Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Если СтрНачинаетсяС(ИНН, "00") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Процедура ЗаполнитьИНН(Свойства, Данные)
	
	ИННЮЛ = Неопределено;
	ИНН = Неопределено;
	
	Если Данные.Свойство("INN") Тогда
		ИНН = Данные.INN;
	ИначеЕсли Данные.Свойство("OID1_2_643_3_131_1_1") Тогда
		ИНН = ПодготовитьСтроку(Данные.OID1_2_643_3_131_1_1);
	КонецЕсли;
	
	Если Данные.Свойство("INNLE") Тогда
		ИННЮЛ = Данные.INNLE;
	ИначеЕсли Данные.Свойство("OID1_2_643_100_4")
			И СтрДлина(Данные.OID1_2_643_100_4) = 10 Тогда
		ИННЮЛ = ПодготовитьСтроку(Данные.OID1_2_643_100_4);
	ИначеЕсли Данные.Свойство("_1_2_643_100_4") Тогда
		ИННЮЛ = ПодготовитьСтроку(Данные._1_2_643_100_4);
	КонецЕсли;
		
	Свойства.ИННЮЛ = ИННЮЛ;
	Свойства.ИНН = ИНН;
	
КонецПроцедуры
	
Функция КонтекстПроверкиУдостоверяющегоЦентраСертификата() Экспорт
	
	Структура = Новый Структура;
	Структура.Вставить("ДанныеУдостоверяющегоЦентра");
	Структура.Вставить("ЗначенияПоиска");
	Структура.Вставить("НаименованиеУдостоверяющегоЦентра", "");
	Структура.Вставить("ДобавкаВремени");
	Структура.Вставить("НаДату");
	Структура.Вставить("ЭтоПроверкаПодписи", Ложь);
	
	Возврат Структура;
	
КонецФункции

Функция ДанныеДляПроверкиУдостоверяющегоЦентра(Сертификат) Экспорт
	
	Результат = Новый Структура("ЗначенияПоиска, НаименованиеУдостоверяющегоЦентра");
	
	СвойстваИздателя = ЭлектроннаяПодписьСлужебныйКлиентСервер.СвойстваИздателяСертификата(Сертификат);
	
	Результат.НаименованиеУдостоверяющегоЦентра = СвойстваИздателя.ОбщееИмя;
	
	ЗначенияПоиска = Новый Массив;
	
	Если СвойстваИздателя.Свойство("ОГРН") И ЗначениеЗаполнено(СвойстваИздателя.ОГРН) Тогда
		ЗначенияПоиска.Добавить(СвойстваИздателя.ОГРН);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СвойстваИздателя.ОбщееИмя) Тогда
		ЗначенияПоиска.Добавить(СвойстваИздателя.ОбщееИмя);
	КонецЕсли;
	
	Если ЗначенияПоиска.Количество() > 0 Тогда
		Результат.ЗначенияПоиска = СтрСоединить(ЗначенияПоиска, ",");
	КонецЕсли;
	
	Возврат Результат;

КонецФункции

Функция ПодготовитьЗначениеПоиска(Знач ЗначениеПоиска) Экспорт
	
	ЗначениеПоиска = ВРег(ЗначениеПоиска);
	ЗначениеПоиска = СтрЗаменить(ЗначениеПоиска, """", "");
	ЗначениеПоиска = СтрЗаменить(ЗначениеПоиска, "«", "");
	ЗначениеПоиска = СтрЗаменить(ЗначениеПоиска, "»", "");
	ЗначениеПоиска = СтрЗаменить(ЗначениеПоиска, "“", "");
	ЗначениеПоиска = СтрЗаменить(ЗначениеПоиска, "”", "");
	
	Возврат ЗначениеПоиска;
	
КонецФункции

// Только для внутреннего использования.
// Возвращаемое значение:
//   см. ЭлектроннаяПодписьСлужебныйКлиентСервер.РезультатПроверкиУдостоверяющегоЦентраПоУмолчанию
//
Функция РезультатПроверкиУдостоверяющегоЦентраСертификата(Сертификат, КонтекстПроверки) Экспорт
	
	ДанныеУдостоверяющегоЦентра = КонтекстПроверки.ДанныеУдостоверяющегоЦентра;
	Если ДанныеУдостоверяющегоЦентра = Неопределено Тогда
		Возврат ЭлектроннаяПодписьСлужебныйКлиентСервер.РезультатПроверкиУдостоверяющегоЦентраПоУмолчанию();
	КонецЕсли;
	
	РезультатПроверкиУдостоверяющегоЦентра = ЭлектроннаяПодписьСлужебныйКлиентСервер.РезультатПроверкиУдостоверяющегоЦентраПоУмолчанию();
	РезультатПроверкиУдостоверяющегоЦентра.НайденВСпискеУдостоверяющихЦентров = Истина;
	РезультатПроверкиУдостоверяющегоЦентра.Государственный = ДанныеУдостоверяющегоЦентра.Государственный;
	
	СвойстваСертификата = ЭлектроннаяПодписьСлужебныйКлиентСервер.СвойстваСертификата(Сертификат, КонтекстПроверки.ДобавкаВремени);
	ДатаВыдачиСертификатаДляСравнения = СвойстваСертификата.ДатаНачала - КонтекстПроверки.ДобавкаВремени;
	
	Количество = ДанныеУдостоверяющегоЦентра.ПериодыДействия.Количество();
	
	ЭтоКвалифицированныйСертификат = Ложь;
	
	Для НомерСКонца = 1 По Количество Цикл
		
		ПериодДействия = ДанныеУдостоверяющегоЦентра.ПериодыДействия[Количество - НомерСКонца];
		
		Если ДатаВыдачиСертификатаДляСравнения < ПериодДействия.ДатаС Тогда
			Продолжить;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(ПериодДействия.ДатаПо) Или ДатаВыдачиСертификатаДляСравнения <= ПериодДействия.ДатаПо Тогда
			ЭтоКвалифицированныйСертификат = Истина;
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Если Не ЭтоКвалифицированныйСертификат Тогда
		Если КонтекстПроверки.ЭтоПроверкаПодписи Тогда
			РезультатПроверкиУдостоверяющегоЦентра.Действует = ДанныеУдостоверяющегоЦентра.РазрешенныйНеаккредитованный;
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru='Сертификат неквалифицированный, так как выпущен удостоверяющим центром %1, не аккредитованным на момент выпуска сертификата.'"),
				КонтекстПроверки.НаименованиеУдостоверяющегоЦентра);
			Если ДанныеУдостоверяющегоЦентра.РазрешенныйНеаккредитованный Тогда
				РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ДополнительныеСведения = ТекстОшибки;
			Иначе
				РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ТекстОшибки = ТекстОшибки;
			КонецЕсли;
		Иначе
			РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ДополнительныеСведения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru='Неквалифицированный сертификат: выпущен удостоверяющим центром %1, не аккредитованным на момент выпуска сертификата.'"),
				КонтекстПроверки.НаименованиеУдостоверяющегоЦентра);
		КонецЕсли;
		Возврат РезультатПроверкиУдостоверяющегоЦентра;
	КонецЕсли;
	
	РезультатПроверкиУдостоверяющегоЦентра.Действует = Ложь;
	РезультатПроверкиУдостоверяющегоЦентра.ЭтоКвалифицированныйСертификат = Истина;
	
	НаДату = КонтекстПроверки.НаДату;
	ДатаДляСравнения = НаДату - КонтекстПроверки.ДобавкаВремени;
	
	ДатаПрекращенияАккредитацииУЦ = Неопределено;
	
	Для НомерСКонца = 1 По Количество Цикл
		
		ПериодДействия = ДанныеУдостоверяющегоЦентра.ПериодыДействия[Количество - НомерСКонца];
		
		Если ДатаДляСравнения < ПериодДействия.ДатаС Тогда
			Продолжить;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(ПериодДействия.ДатаПо) Или ДатаДляСравнения <= ПериодДействия.ДатаПо Тогда
			РезультатПроверкиУдостоверяющегоЦентра.Действует = Истина;
			Прервать;
		КонецЕсли;
		
		Если ДатаДляСравнения > ПериодДействия.ДатаПо Тогда
			РезультатПроверкиУдостоверяющегоЦентра.Действует = Ложь;
			ДатаПрекращенияАккредитацииУЦ = ПериодДействия.ДатаПо + КонтекстПроверки.ДобавкаВремени;
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	СвойстваСубъекта = ЭлектроннаяПодписьСлужебныйКлиентСервер.СвойстваСубъектаСертификата(Сертификат);
	ЭтоИННФизЛица = ЗначениеЗаполнено(СвойстваСубъекта.ИНН) И ЭтоИННФизЛица(СвойстваСубъекта.ИНН);
	
	ЭтоЮридическоеЛицо = ЗначениеЗаполнено(СвойстваСубъекта.ИННЮЛ) Или Не ЭтоИННФизЛица;
	ЭтоИндивидуальныйПредприниматель = ЗначениеЗаполнено(СвойстваСубъекта.ОГРНИП);
	ЭтоФизическоеЛицо = Не ЭтоЮридическоеЛицо И Не ЭтоИндивидуальныйПредприниматель;
	
	ДатаПрекращенияДействия = ДанныеУдостоверяющегоЦентра.ДругиеНастройки.Получить("ДатаПрекращенияДействияСертификатовВыданныхКоммерческимиУЦ");
	Если ЗначениеЗаполнено(ДатаПрекращенияДействия) Тогда
		ДатаПрекращенияДействия = ДатаПрекращенияДействия + КонтекстПроверки.ДобавкаВремени;
	КонецЕсли;
	
	ВозможенПеревыпуск = ЭтоФизическоеЛицо Или Не ДанныеУдостоверяющегоЦентра.Государственный;
	
	// Аккредитация удостоверяющего центра прекращена.
	Если Не РезультатПроверкиУдостоверяющегоЦентра.Действует Тогда
		
		Если ДанныеУдостоверяющегоЦентра.РазрешенныйНеаккредитованный Тогда
			РезультатПроверкиУдостоверяющегоЦентра.Действует = Истина;
			РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ДополнительныеСведения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Сертификат выдан удостоверяющим центром %1, аккредитация которого прекращена %2, но использование разрешено администратором.'"),
				КонтекстПроверки.НаименованиеУдостоверяющегоЦентра,
				Формат(ДатаПрекращенияАккредитацииУЦ, "ДЛФ=DT"));
			Возврат РезультатПроверкиУдостоверяющегоЦентра;
		КонецЕсли;
		
		РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Сертификат не действует с %1, так как аккредитация удостоверяющего центра %2, выдавшего сертификат, прекращена.'"),
				Формат(ДатаПрекращенияАккредитацииУЦ, "ДЛФ=DT"), КонтекстПроверки.НаименованиеУдостоверяющегоЦентра);
			
		Если Не КонтекстПроверки.ЭтоПроверкаПодписи Тогда
			
			РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ВозможенПеревыпуск = ВозможенПеревыпуск;
			
			Если ВозможенПеревыпуск Тогда
				РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.Решение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Подайте <a href = ""%1"">заявление</a> на новый сертификат или добавьте удостоверяющий центр %2 в <a href = ""%3"">список разрешенных</a> неаккредитованных УЦ.'"),
					"ПодатьЗаявлениеНаСертификат", КонтекстПроверки.НаименованиеУдостоверяющегоЦентра,
					"ДобавитьУдостоверяющийЦентрВСписокРазрешенныхНеаккредитованных");
			Иначе
				РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.Решение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Получите новый сертификат в <a href = ""%1"">соответствующем удостоверяющем центре</a> или добавьте удостоверяющий центр %2 в <a href = ""%3"">список разрешенных</a> неаккредитованных УЦ.'"),
					СсылкаНаСтатьюОбУдостоверяющихЦентрах(), КонтекстПроверки.НаименованиеУдостоверяющегоЦентра,
					"ДобавитьУдостоверяющийЦентрВСписокРазрешенныхНеаккредитованных");
			КонецЕсли;
			
		КонецЕсли;
		
		Возврат РезультатПроверкиУдостоверяющегоЦентра;
		
	КонецЕсли;
	
	ДатаПредупреждения = Неопределено;
	
	// Сертификаты ЮЛ и ИП, выданные коммерческими АУЦ не действуют или не будут действовать.
	Если ДатаПрекращенияДействия <> Неопределено И Не ДанныеУдостоверяющегоЦентра.Государственный И Не ЭтоФизическоеЛицо И (НаДату >= ДатаПрекращенияДействия 
			Или НаДату + 30*24*60*60 >= ДатаПрекращенияДействия И Не КонтекстПроверки.ЭтоПроверкаПодписи) Тогда

		РезультатПроверкиУдостоверяющегоЦентра.Действует = (НаДату < ДатаПрекращенияДействия);
		РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ВозможенПеревыпуск = Истина;

		Если НаДату < ДатаПрекращенияДействия Тогда
			Если ЭтоИндивидуальныйПредприниматель Тогда
				ТекстОшибки = НСтр(
					"ru = 'С %1 нельзя будет подписывать документы этим сертификатом, так как не будут действовать сертификаты, выданные коммерческими аккредитованными удостоверяющими центрами индивидуальным предпринимателям.'");
			Иначе
				ТекстОшибки = НСтр(
					"ru = 'С %1 нельзя будет подписывать документы этим сертификатом, так как не будут действовать сертификаты, выданные коммерческими аккредитованными удостоверяющими центрами юридическим лицам и их сотрудникам.'");
			КонецЕсли;
			ДатаПредупреждения = ДатаПрекращенияДействия;
		Иначе
			Если ЭтоИндивидуальныйПредприниматель Тогда
				ТекстОшибки = НСтр(
					"ru = 'Сертификат не действует c %1, так как с этой даты не действуют сертификаты, выданные коммерческими аккредитованными удостоверяющими центрами индивидуальным предпринимателям.'");
			Иначе
				ТекстОшибки = НСтр(
					"ru = 'Сертификат не действует c %1, так как с этой даты не действуют сертификаты, выданные коммерческими аккредитованными удостоверяющими центрами юридическим лицам и их сотрудникам.'");
			КонецЕсли;
		КонецЕсли;

		РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ТекстОшибки, Формат(ДатаПрекращенияДействия, "ДЛФ=D"));

		Если Не КонтекстПроверки.ЭтоПроверкаПодписи Тогда

			РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ДополнительныеСведения = РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ТекстОшибки;
			РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.Решение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Подайте <a href = ""%1"">заявление</a> на новый сертификат.'"), "ПодатьЗаявлениеНаСертификат");
		
		КонецЕсли;
		
	КонецЕсли;
	
	Если Не РезультатПроверкиУдостоверяющегоЦентра.Действует Или КонтекстПроверки.ЭтоПроверкаПодписи Тогда
		
		Возврат РезультатПроверкиУдостоверяющегоЦентра;
		
	КонецЕсли;
	
	Если СвойстваСертификата.ДействителенДо < НаДату Тогда
		Возврат РезультатПроверкиУдостоверяющегоЦентра;
	КонецЕсли;
	
	// Аккредитация удостоверяющего центра скоро закончится.
	Если ЗначениеЗаполнено(ДанныеУдостоверяющегоЦентра.ДатаОкончанияДействия) Тогда
		
		ДатаОкончанияДействия = ДанныеУдостоверяющегоЦентра.ДатаОкончанияДействия + КонтекстПроверки.ДобавкаВремени;
		
		Если ДатаОкончанияДействия > НаДату 
			И (ДатаПредупреждения = Неопределено Или ДатаОкончанияДействия < ДатаПредупреждения) Тогда
			
			ДатаПредупреждения = ДатаОкончанияДействия;
			
			РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'С %1 нельзя будет подписывать документы этим сертификатом, так как аккредитация удостоверяющего центра %2, выдавшего сертификат, будет прекращена.'"),
			Формат(ДатаОкончанияДействия, "ДЛФ=DT"), КонтекстПроверки.НаименованиеУдостоверяющегоЦентра);
			
			РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ВозможенПеревыпуск = ВозможенПеревыпуск;
			
			Если ВозможенПеревыпуск Тогда
				РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.Решение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Подайте <a href = ""%1"">заявление</a> на новый сертификат.'"), "ПодатьЗаявлениеНаСертификат");
			Иначе
				РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.Решение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Получите новый сертификат в <a href = ""%1"">соответствующем удостоверяющем центре</a>.'"),
					СсылкаНаСтатьюОбУдостоверяющихЦентрах());
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	// Срок действия сертификата скоро закончится.
	Если СвойстваСертификата.ДействителенДо <= НаДату + КоличествоДнейДляОповещенияОбОкончанииСрокаДействия()*24*60*60
		И (ДатаПредупреждения = Неопределено Или СвойстваСертификата.ДействителенДо < ДатаПредупреждения)Тогда
		
		РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'С %1 нельзя будет подписывать документы этим сертификатом, так как срок действия сертификата закончится.'"),
			Формат(СвойстваСертификата.ДействителенДо, "ДЛФ=DT"));
		
		РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.ВозможенПеревыпуск = ВозможенПеревыпуск;
			
		Если ВозможенПеревыпуск Тогда
			РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.Решение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Подайте <a href = ""%1"">заявление</a> на новый сертификат.'"), "ПодатьЗаявлениеНаСертификат");
		Иначе
			РезультатПроверкиУдостоверяющегоЦентра.Предупреждение.Решение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Получите новый сертификат в <a href = ""%1"">соответствующем удостоверяющем центре</a>.'"),
					СсылкаНаСтатьюОбУдостоверяющихЦентрах());
		КонецЕсли;
	КонецЕсли;
	
	Возврат РезультатПроверкиУдостоверяющегоЦентра;
	
КонецФункции

Функция КоличествоДнейДляОповещенияОбОкончанииСрокаДействия()
	
	Возврат 30;
	
КонецФункции

Функция СсылкаНаСтатьюОбУдостоверяющихЦентрах() Экспорт
	
	Возврат "https://its.1c.ru/bmk/esig_uc";
	
КонецФункции

Функция ИмяПрограммыVipNet() Экспорт
	Возврат "ViPNet CSP";
КонецФункции

Функция ИмяПрограммыКриптоПро() Экспорт
	Возврат "КриптоПро CSP";
КонецФункции

// Конец Локализация

#КонецОбласти