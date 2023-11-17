///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Определяет объекты конфигурации, в формах списках которых размещены команды учета оригиналов первичных документов,
//
// Параметры:
//  СписокОбъектов - Массив из Строка - менеджеры объектов с процедурой ДобавитьКомандыПечати.
//
Процедура ПриОпределенииОбъектовСКомандамиУчетаОригиналов(СписокОбъектов) Экспорт
	
	

КонецПроцедуры

// Определяет объекты конфигурации, для которых отслеживание состояний будет в разрезе сотрудников.
//
// Параметры:
//  СписокОбъектов - Соответствие из КлючИЗначение:
//          * Ключ - ОбъектМетаданных.
//          * Значение - Строка - наименование табличной части, в которой хранятся сотрудники.
//
Процедура ПриОпределенииМногосотрудниковыхДокументов(СписокОбъектов) Экспорт
	
	

КонецПроцедуры

// Заполняет таблицу значений учета оригиналов
// Если тело процедуры оставить пустым - состояния будут отслеживаться по всем печатным формам подключенных объектов.
// Если в таблицу значений добавить объекты, подключенные к подсистеме учета оригиналов, и их печатные формы,
// то состояния будут отслеживаться только по ним.
//  
// Параметры:
//   ТаблицаУчетаОригиналов - ТаблицаЗначений - коллекция объектов и макетов по которым требуется вести учет оригиналов:
//              * ОбъектМетаданных - ОбъектМетаданных.
//              * Идентификатор - Строка - идентификатор макета.
//
// Пример:
//	 НоваяСтрока = ТаблицаУчетаОригиналов.Добавить();
//	 НоваяСтрока.ОбъектМетаданных = Метаданные.Документы._ДемоРеализацияТоваров;
//	 НоваяСтрока.Идентификатор = "РасходнаяНакладная";
//
Процедура ЗаполнитьТаблицуУчетаОригиналов(ТаблицаУчетаОригиналов) Экспорт	
	
	

КонецПроцедуры

#КонецОбласти
