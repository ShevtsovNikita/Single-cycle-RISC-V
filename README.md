# Single-cycle-RISC-V
Здесь пошагово расписан процесс моей разработки однотактового процессора с набором инструкций RV32I в ходе выполнения лабораторного практикума по дисциплине "Архитектуры процессорных систем"
## 1 лабораторная:
Задание: ознакомиться с созданием проектов в Vivado, разработать арифметико-логическое утройство (ALU.sv) которое будет выполнять команды с фото, а так же написать testbench к модулю.![image](https://user-images.githubusercontent.com/116370315/212533299-6913dedc-84b5-46d0-9ac0-99269fe41af9.png)

Что было сделано: выполнен модуль достаточно примитивно, так как это первый проект в Vivado и на SystemVerilog в целом, где так же надо было познакомиться с верификацией. Тестировал модуль через написанный тестбенч и файл .mem с тестовыми векторами.
## 2 лабораторная:
Задание: разработка модулей регистрового файла, модулей памяти инструкций и данный (файлов этой работы нет, так как все будет переделано в лабораторной работе номер 5 в принстонскую с единой памятью).
## 3 лабораторная:
Разработка устройства управления, которое поддерживает набор инструкций с фото 3_lab_task.png (main_decoder.sv). Тестировался модуль при помощи написанного преподавателям testbench'а.
## 4 лабораторная:
Тракт данных RISC-V - объединение ранее написанных модулей в единую схему (схема изображена на фото data_path.png). Проверка осуществлялась с помощью небольшой программки на языке ассемблера (без команд работы с памятью, так как их поддержка будет добавлена позже).
## 5 лабораторная:
Разработка модуля LSU и перевод процессора на принстонскую архитектуру, разработка модуля RAM.sv единой памяти команд и данных. Добавлена поддержка команд lw и sw (а также lh и т.д.). Тестировалась работа модулей с помощью набора ассемблерных команд работы с памятью и анализа временных диаграмм.
## 6 лабораторная:
Разработка и подключение к процессору системы прерываний. 
Был разработан модуль обработки прерываний Interrupt_Controller.sv с циклическим опросом и модуль с регистрами специального назначения CSR.sv
Тестировалась работа с помощью программы на языке ассемблера, где запускался бесконечный цикл, и в определенный момент в времени (заданные мной в тестбенче) формировался сигнал прерывания.
## 7 лабораторная:
Задание: подключение периферии к процессору.
Что было сделано:
Был написан модуль Adres_decoder.sv, который перенаправлял сигналы процессора к памяти/светодиодам/регистрам клавиатуры в зависимости от адреса ячейки памяти. Так же был написан модуль контроллера клавиатуры с интерфейсом PS/2 (простой,  на уровне считывания кода нажатой клавиши).
Проверка осуществлялась на практике - я загрузил проект в плис, подключил к ней клавиатуру и проверил работу (код нажатой клавиши должен выводиться на диоды и на семисегментники в шестнадцатиричном формате) отчет по результатам - в видео по ссылке.
## 8 лабораторная:
Задание: ознакомиться с процессом компиляции программы на языке высокого уровня в программу на языке ассемблера и проверить правильность ее выполнения на своем процессоре. 
Что было сделано: с помощью кросскомпилятора программа на языке С была переведена в машинные коды, которые были загружены в модуль памяти RAM.sv
