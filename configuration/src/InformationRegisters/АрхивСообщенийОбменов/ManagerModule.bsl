///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

Процедура ПоместитьСообщениеВАрхив(УзелИнформационнойБазы, ПутьКИсходномуФайлу) Экспорт
	
	Если НЕ ЗначениеЗаполнено(УзелИнформационнойБазы) Тогда
		Возврат;
	КонецЕсли;
	
	Настройки = РегистрыСведений.НастройкиАрхиваСообщенийОбменов.ПолучитьНастройки(УзелИнформационнойБазы);
	
	Если Настройки = Неопределено Или Настройки.КоличествоФайлов = 0 Тогда
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию();
	
	Попытка
		
		ПоместитьВАрхив(УзелИнформационнойБазы, ПутьКИсходномуФайлу, Настройки);
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		
		СообщениеОбОшибке = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрацииПомещениеСообщенияВАрхив(),
			УровеньЖурналаРегистрации.Ошибка, , , СообщениеОбОшибке);
		
	КонецПопытки;
	
КонецПроцедуры 

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПоместитьВАрхив(УзелИнформационнойБазы, ПутьКИсходномуФайлу, Настройки)

	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.АрхивСообщенийОбменов");
	ЭлементБлокировки.УстановитьЗначение("УзелИнформационнойБазы", УзелИнформационнойБазы);
	Блокировка.Заблокировать();
	
	Набор = РегистрыСведений.АрхивСообщенийОбменов.СоздатьНаборЗаписей();
	Набор.Отбор.УзелИнформационнойБазы.Установить(УзелИнформационнойБазы);
	Набор.Прочитать();
	
	КоличествоЗаписей = Набор.Количество();
	Для Сч = 1 По КоличествоЗаписей Цикл
		
		Индекс = КоличествоЗаписей - Сч;
		Запись = Набор[Индекс];
		Если Запись.ФайлБольше100Мб Тогда
			Набор.Удалить(Индекс);
		КонецЕсли;
		
	КонецЦикла;
	
	Для Сч = 1 По Набор.Количество() - Настройки.КоличествоФайлов + 1 Цикл
		
		Запись = Набор.Получить(0);
		
		Если Запись.ПолноеИмяФайла <> "" Тогда
			УдалитьФайлы(Запись.ПолноеИмяФайла);
		КонецЕсли;
			
		Набор.Удалить(0);
		
	КонецЦикла;
		
	Если СтрЗаканчиваетсяНа(НРег(ПутьКИсходномуФайлу), "zip") Тогда
		РасширениеФайла = "zip";
	Иначе
		РасширениеФайла = "xml";
	КонецЕсли;
	
	УдалитьФайлПослеПомещения = Ложь;
	Если Настройки.СжиматьФайлы И РасширениеФайла <> "zip" Тогда
		
		УдалитьФайлПослеПомещения = Истина;
		РасширениеФайла = "zip";
		ИмяФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);
		
		ОбменДаннымиСервер.ЗапаковатьВZipФайл(ИмяФайла, ПутьКИсходномуФайлу);
		
	Иначе
		
		ИмяФайла = ПутьКИсходномуФайлу;
		
	КонецЕсли;
	
	Файл = Новый Файл(ИмяФайла);
	РазмерФайла = Файл.Размер() / (1024 * 1024); 
	
	Шаблон = "%1_%2_%3";
	ИмяФайлаВАрхиве = СтрШаблон(Шаблон, 
		УзелИнформационнойБазы.Код,
		УзелИнформационнойБазы.НомерПринятого,
		Строка(Новый УникальныйИдентификатор));
	
	НовыйАрхив = Набор.Добавить();
	НовыйАрхив.УзелИнформационнойБазы = УзелИнформационнойБазы;
	НовыйАрхив.Период = ТекущаяДатаСеанса();
	НовыйАрхив.НомерПринятогоСообщения = УзелИнформационнойБазы.НомерПринятого;
	НовыйАрхив.РазмерФайла = РазмерФайла;
	НовыйАрхив.ИмяФайла = ИмяФайлаВАрхиве;
	НовыйАрхив.РасширениеФайла = РасширениеФайла;
	
	Если Настройки.ХранитьНаДиске Тогда
		
		Шаблон = "%1%2.%3";
		
		ИмяПапки = Настройки.ПолныйПуть;
				
		ПолноеИмяФайлаВПапке = СтроковыеФункции.ФорматированнаяСтрока(Шаблон,
			ИмяПапки,
			ИмяФайлаВАрхиве,
			РасширениеФайла);
			
		КопироватьФайл(ИмяФайла, ПолноеИмяФайлаВПапке);
		НовыйАрхив.ПолноеИмяФайла = ПолноеИмяФайлаВПапке;
			
	Иначе
				
		Если ОбщегоНазначения.РазделениеВключено() И РазмерФайла > 100 Тогда
			
			НовыйАрхив.ФайлБольше100Мб = Истина;
			
			Причина = НСтр("ru = 'Сообщение обмена больше 100 Мб. Файл не был помещен в архив.'");
		
			ПараметрыЗаписи = Новый Структура;
			ПараметрыЗаписи.Вставить("УзелИнформационнойБазы", УзелИнформационнойБазы);
			ПараметрыЗаписи.Вставить("Причина", Причина);
			ПараметрыЗаписи.Вставить("ТипПроблемы", Перечисления.ТипыПроблемОбменаДанными.СообщениеОбменаНеПомещеноВАрхив);
			
			РегистрыСведений.РезультатыОбменаДанными.ДобавитьЗаписьОРезультатахОбмена(ПараметрыЗаписи);
	
		Иначе
			
			НовыйАрхив.Хранилище = Новый ХранилищеЗначения(Новый ДвоичныеДанные(ИмяФайла));
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если УдалитьФайлПослеПомещения Тогда
		УдалитьФайлы(ИмяФайла);
	КонецЕсли;

	Набор.Записать();

КонецПроцедуры

Функция СобытиеЖурналаРегистрацииПомещениеСообщенияВАрхив()
	
	Возврат НСтр("ru = 'Обмен данными.Помещение сообщения в архив'", ОбщегоНазначения.КодОсновногоЯзыка());
	
КонецФункции

#КонецОбласти

#КонецЕсли