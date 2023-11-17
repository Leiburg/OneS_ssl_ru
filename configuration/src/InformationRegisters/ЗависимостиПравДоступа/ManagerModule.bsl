///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Процедура обновляет данные регистра, если прикладной разработчик
// изменил зависимости в переопределяемом модуле.
//
// Параметры:
//  ЕстьИзменения - Булево - (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьДанныеРегистра(ЕстьИзменения = Неопределено) Экспорт
	
	СтандартныеПодсистемыСервер.ПроверитьДинамическоеОбновлениеВерсииПрограммы();
	УстановитьПривилегированныйРежим(Истина);
	
	ЗависимостиПравДоступа = ЗависимостиПравДоступа();
	
	ТекстЗапросовВременныхТаблиц =
	"ВЫБРАТЬ
	|	НовыеДанные.ПодчиненнаяТаблица,
	|	НовыеДанные.ТипВедущейТаблицы
	|ПОМЕСТИТЬ НовыеДанные
	|ИЗ
	|	&ЗависимостиПравДоступа КАК НовыеДанные";
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	НовыеДанные.ПодчиненнаяТаблица,
	|	НовыеДанные.ТипВедущейТаблицы,
	|	&ПодстановкаПоляВидИзмененияСтроки
	|ИЗ
	|	НовыеДанные КАК НовыеДанные";
	
	// Подготовка выбираемых полей с необязательным отбором.
	Поля = Новый Массив;
	Поля.Добавить(Новый Структура("ПодчиненнаяТаблица"));
	Поля.Добавить(Новый Структура("ТипВедущейТаблицы"));
	
	Запрос = Новый Запрос;
	ЗависимостиПравДоступа.Свернуть("ПодчиненнаяТаблица, ТипВедущейТаблицы");
	Запрос.УстановитьПараметр("ЗависимостиПравДоступа", ЗависимостиПравДоступа);
	
	Запрос.Текст = УправлениеДоступомСлужебный.ТекстЗапросаВыбораИзменений(
		ТекстЗапроса, Поля, "РегистрСведений.ЗависимостиПравДоступа", ТекстЗапросовВременныхТаблиц);
	
	Блокировка = Новый БлокировкаДанных;
	Блокировка.Добавить("РегистрСведений.ЗависимостиПравДоступа");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		Данные = Новый Структура;
		Данные.Вставить("МенеджерРегистра",      РегистрыСведений.ЗависимостиПравДоступа);
		Данные.Вставить("ИзмененияСоставаСтрок", Запрос.Выполнить().Выгрузить());
		
		УправлениеДоступомСлужебный.ОбновитьРегистрСведений(Данные, ЕстьИзменения);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращаемое значение:
//  ТаблицаЗначений:
//   * ПодчиненнаяТаблица - СправочникСсылка.ИдентификаторыОбъектовМетаданных
//   * ТипВедущейТаблицы  - ЛюбаяСсылка
//
Функция ЗависимостиПравДоступа() Экспорт
	
	ЗависимостиПравДоступа = СоздатьНаборЗаписей();
	
	Таблица = Новый ТаблицаЗначений;
	Таблица.Колонки.Добавить("ПодчиненнаяТаблица", Новый ОписаниеТипов("Строка"));
	Таблица.Колонки.Добавить("ВедущаяТаблица",     Новый ОписаниеТипов("Строка"));
	
	ИнтеграцияПодсистемБСП.ПриЗаполненииЗависимостейПравДоступа(Таблица);
	УправлениеДоступомПереопределяемый.ПриЗаполненииЗависимостейПравДоступа(Таблица);
	
	ЗависимостиПравДоступа = СоздатьНаборЗаписей().Выгрузить();
	Для каждого Строка Из Таблица Цикл
		НоваяСтрока = ЗависимостиПравДоступа.Добавить();
		
		ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоПолномуИмени(Строка.ПодчиненнаяТаблица);
		Если ОбъектМетаданных = Неопределено Тогда
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка в процедуре %1
				           |общего модуля %2.
				           |
				           |Не найдена подчиненная таблица ""%3"".'"),
				"ПриЗаполненииЗависимостейПравДоступа",
				"УправлениеДоступомПереопределяемый",
				Строка.ПодчиненнаяТаблица);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
		НоваяСтрока.ПодчиненнаяТаблица = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(
			Строка.ПодчиненнаяТаблица);
		
		ОбъектМетаданных = ОбщегоНазначения.ОбъектМетаданныхПоПолномуИмени(Строка.ВедущаяТаблица);
		Если ОбъектМетаданных = Неопределено Тогда
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка в процедуре %1
				           |общего модуля %2.
				           |
				           |Не найдена ведущая таблица ""%3"".'"),
				"ПриЗаполненииЗависимостейПравДоступа",
				"УправлениеДоступомПереопределяемый",
				Строка.ВедущаяТаблица);
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
		НоваяСтрока.ТипВедущейТаблицы = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(
			Строка.ВедущаяТаблица).ПустаяСсылка();
	КонецЦикла;
	
	Возврат ЗависимостиПравДоступа;
	
КонецФункции

#КонецОбласти

#КонецЕсли