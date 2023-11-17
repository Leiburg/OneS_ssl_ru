///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция ПеревестиТекст(Текст, ЯзыкПеревода = Неопределено, ИсходныйЯзык = Неопределено) Экспорт
	
	Если Не ЗначениеЗаполнено(Текст) Тогда
		Возврат Текст;
	КонецЕсли;
	
	Возврат ПеревестиТексты(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Текст), ЯзыкПеревода, ИсходныйЯзык)[Текст];
	
КонецФункции

Функция ПеревестиТексты(Тексты, ЯзыкПеревода = Неопределено, ИсходныйЯзык = Неопределено) Экспорт
	
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр("ПеревестиТексты", "Тексты", Тексты, Тип("Массив"));
	
	Если Не ЗначениеЗаполнено(ЯзыкПеревода) Тогда
		ЯзыкПеревода = ОбщегоНазначения.КодОсновногоЯзыка();
	КонецЕсли;
	
	ИмяХоста = "translation.googleapis.com";
	
	УстановитьПривилегированныйРежим(Истина);
	HTTPЗапрос = Новый HTTPЗапрос("/language/translate/v2?key=" + НастройкиАвторизации().КлючAPI);
	УстановитьПривилегированныйРежим(Ложь);
	
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("format", "text");
	ПараметрыЗапроса.Вставить("q", Тексты);
	ПараметрыЗапроса.Вставить("target", ЯзыкПеревода);
	
	Если ЗначениеЗаполнено(ИсходныйЯзык) Тогда
		ПараметрыЗапроса.Вставить("source", ИсходныйЯзык);
	КонецЕсли;
	
	HTTPЗапрос.УстановитьТелоИзСтроки(ОбщегоНазначения.ЗначениеВJSON(ПараметрыЗапроса));
	РезультатЗапроса = ВыполнитьЗапрос(HTTPЗапрос, ИмяХоста);
	
	Если Не РезультатЗапроса.ЗапросВыполнен Тогда
		ВызватьИсключение ТекстОшибки(НСтр("ru = 'Не удалось выполнить перевод текста.'"));
	КонецЕсли;
	
	ОтветСервера = ОбщегоНазначения.JSONВЗначение(РезультатЗапроса.ОтветСервера);
	
	Результат = Новый Соответствие;
	Для Индекс = 0 По Тексты.ВГраница() Цикл
		Перевод = ОтветСервера["data"]["translations"][Индекс];
		Результат.Вставить(Тексты[Индекс], Перевод["translatedText"]);
		Если Не ЗначениеЗаполнено(ИсходныйЯзык) Тогда
			ИсходныйЯзык = Перевод["detectedSourceLanguage"];
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция МаксимальныйРазмерПорции() Экспорт
	
	Возврат 10000;
	
КонецФункции

Функция ДоступныеЯзыки() Экспорт
	
	ИмяХоста = "translation.googleapis.com";
	
	УстановитьПривилегированныйРежим(Истина);
	HTTPЗапрос = Новый HTTPЗапрос("/language/translate/v2/languages?key=" + НастройкиАвторизации().КлючAPI);
	УстановитьПривилегированныйРежим(Ложь);
	
	РезультатЗапроса = ВыполнитьЗапрос(HTTPЗапрос, ИмяХоста);
	
	Если Не РезультатЗапроса.ЗапросВыполнен Тогда
		ВызватьИсключение ТекстОшибки(НСтр("ru = 'Не удалось получить список доступных языков.'"));
	КонецЕсли;
	
	Результат = Новый Массив;
	ДоступныеЯзыки = ОбщегоНазначения.JSONВЗначение(РезультатЗапроса.ОтветСервера);
	Для Каждого Язык Из ДоступныеЯзыки["data"]["languages"] Цикл
		КодЯзыка = Язык["language"];
		Результат.Добавить(КодЯзыка);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ВыполнитьЗапрос(Знач HTTPЗапрос, Знач ИмяХоста)
	
	Прокси = ПолучениеФайловИзИнтернета.ПолучитьПрокси("https");
	ЗащищенноеСоединение = ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение();
	
	Попытка
		Соединение = Новый HTTPСоединение(ИмяХоста, , , , Прокси, 60, ЗащищенноеСоединение);
		HTTPОтвет = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
	Исключение
		ЗаписатьОшибкуВЖурналРегистрации(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось установить соединение с сервером %1 по причине:
			|%2'"), ИмяХоста, ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())));
		ВызватьИсключение;
	КонецПопытки;
	
	Результат = Новый Структура;
	Результат.Вставить("ЗапросВыполнен", Ложь);
	Результат.Вставить("ОтветСервера", "");
	
	Если HTTPОтвет.КодСостояния <> 200 Тогда
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Запрос ""%1"" не выполнен. Код состояния: %2.'"),
			HTTPЗапрос.АдресРесурса,
			HTTPОтвет.КодСостояния) + Символы.ПС + HTTPОтвет.ПолучитьТелоКакСтроку();
		ЗаписатьОшибкуВЖурналРегистрации(ТекстОшибки);
	КонецЕсли;
		
	Если HTTPОтвет.КодСостояния = 401 
		Или HTTPОтвет.КодСостояния = 403 Тогда
		ИнформацияОбОшибке = ОбщегоНазначения.JSONВЗначение(HTTPОтвет.ПолучитьТелоКакСтроку());
		ВызватьИсключение ИнформацияОбОшибке["error"]["message"];
	КонецЕсли;
	
	Результат.ЗапросВыполнен = HTTPОтвет.КодСостояния = 200;
	Результат.ОтветСервера = HTTPОтвет.ПолучитьТелоКакСтроку();
	
	Возврат Результат;
	
КонецФункции

Функция НастройкиАвторизации() Экспорт
	
	ИменаПараметров = "КлючAPI";
	Результат = Новый Структура(ИменаПараметров);
	
	Если ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Владелец = ОбщегоНазначения.ИдентификаторОбъектаМетаданных("Константа.СервисПереводаТекста");
		Настройки = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(Владелец, ИменаПараметров);
		
		Если ТипЗнч(Настройки) = Тип("Структура") Тогда
			ЗаполнитьЗначенияСвойств(Результат, Настройки);
		ИначеЕсли ТипЗнч(Настройки) = Тип("Строка") Тогда
			Результат.КлючAPI = Настройки;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Параметры:
//  Настройки - см. ПереводТекстаНаДругиеЯзыки.НастройкиСервисаПереводаТекста
//
Процедура ПриОпределенииНастроек(Настройки) Экспорт
	
	Настройки.ИнструкцияПоПодключению = СтроковыеФункции.ФорматированнаяСтрока(НСтр(
		"ru = 'Как настроить:
		|1. Активируйте платежный аккаунт в <a href = ""%1"">Google Cloud</a>.
		|2. На странице <a href = ""%2"">Учетные данные</a> нажмите на кнопку <b>Создать учетные данные</b>, выберите <b>Ключ API</b>.
		|3. Скопируйте полученную строку из поля <b>Ваш ключ API</b> в поле <b>Ключ API</b>.'"),
		"https://console.cloud.google.com/billing",
		"https://console.cloud.google.com/apis/credentials");
	
	Параметр = Настройки.ПараметрыАвторизации.Добавить();
	Параметр.Имя = "КлючAPI";
	Параметр.Представление = НСтр("ru = 'Ключ API'");
	Параметр.ОтображениеПодсказки = ОтображениеПодсказки.ОтображатьСверху;
	
КонецПроцедуры

Функция НастройкаВыполнена() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Возврат ЗначениеЗаполнено(НастройкиАвторизации().КлючAPI);
	
КонецФункции

Процедура ЗаписатьОшибкуВЖурналРегистрации(Комментарий)
	
	ЗаписьЖурналаРегистрации(НСтр("ru = 'Перевод текста'", ОбщегоНазначения.КодОсновногоЯзыка()),
		УровеньЖурналаРегистрации.Ошибка, , Перечисления.СервисыПереводаТекста.ЯндексПереводчик, Комментарий);
	
КонецПроцедуры

Функция ТекстОшибки(ТекстОшибки)
	
	Если Пользователи.ЭтоПолноправныйПользователь() Тогда
		Возврат ТекстОшибки + Символы.ПС + НСтр("ru = 'Подробности см. в журнале регистрации.'");
	КонецЕсли;
	
	Возврат ТекстОшибки + Символы.ПС + НСтр("ru = 'Обратитесь к администратору.'");
	
КонецФункции

// Возвращает список разрешений для использования сервиса перевода.
//
// Возвращаемое значение:
//  Массив
//
Функция Разрешения() Экспорт
	
	Протокол = "HTTPS";
	Адрес = "translation.googleapis.com";
	Порт = Неопределено;
	Описание = НСтр("ru = 'Сервис перевода текста Google Translate'");
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Разрешение = МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса(Протокол, Адрес, Порт, Описание);
	
	Разрешения = Новый Массив;
	Разрешения.Добавить(Разрешение);
	
	Возврат Разрешения;
	
КонецФункции

#КонецОбласти
