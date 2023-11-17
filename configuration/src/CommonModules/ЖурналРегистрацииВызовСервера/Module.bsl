///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Процедура пакетной записи сообщений в журнал регистрации.
// После записи переменная СобытияДляЖурналаРегистрации очищается.
//
// Параметры:
//  СобытияДляЖурналаРегистрации - СписокЗначений - где Значение - структура со свойствами:
//              * ИмяСобытия  - Строка - имя записываемого события.
//              * ПредставлениеУровня  - Строка - представление значений коллекции УровеньЖурналаРегистрации.
//                                       Доступные значения: "Информация", "Ошибка", "Предупреждение", "Примечание".
//              * Комментарий - Строка - комментарий события.
//              * ДатаСобытия - Дата   - дата события, подставляется в комментарий при записи.
//
Процедура ЗаписатьСобытияВЖурналРегистрации(СобытияДляЖурналаРегистрации) Экспорт
	
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СобытияДляЖурналаРегистрации);
	
КонецПроцедуры

#КонецОбласти
