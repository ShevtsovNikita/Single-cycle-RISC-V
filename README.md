# Ход выполнения лабраторных работ:

## 1 лабораторная:
Задание: разработать арифметико-логическое утройство, которое будет выполнять команды с фото, а так же написать testbench к модулю.

![image](https://user-images.githubusercontent.com/116370315/212534549-533d5842-3597-4873-b766-5f0f88408222.png)

Ход работы: познакомился с созданием проектов в Vivado, разработал модуль [ALU.sv](ALU.sv). Выполнен он достаточно примитивно, так как это первый проект в Vivado и на SystemVerilog в целом, где так же надо было познакомиться с верификацией. Тестировал модуль через написанный тестбенч с подключением файла .mem с тестовыми векторами.

## 2 лабораторная:
Задание: разработать модуль регистрового файла [register_file.sv](register_file.sv), модули памяти инструкций и данных (далее модули памяти будут переделаны в лабораторной работе номер 5 в принстонскую с единой памятью). 

![image](https://user-images.githubusercontent.com/116370315/212534641-5ff5d836-a1ef-4590-880b-ee71a703e0aa.png)

## 3 лабораторная:
Задание: разработать устройство управления, которое поддерживает следующий набор инструкций. 

![image](https://user-images.githubusercontent.com/116370315/212534720-0083f4f6-aba0-4e1c-9050-1ed907fc9597.png)

Ход работы: долго изучал кодирование инструкций и управляющие сигналы, разработал модуль декодирования инструкций [main_decoder.sv](main_decoder.sv), верификация проводилась с помощью написанного преподавателями тестбенча.

## 4 лабораторная:
Задание: объединить все написанные ранее модули в систему, то есть сформировать тракт данных RISC-V, показанный на фото. 

![image](https://user-images.githubusercontent.com/116370315/212534796-8221b93f-7adb-477b-8381-ce48e74b592f.png)

Ход работы: соединил все ранее написанные модули в модуль [cpu_main.sv](cpu_main.sv), основная часть времени при выполнении этой работы ушла на верификацию, которая осуществлялась с помощью небольшой программки на языке ассемблера - реализация умножения через сдвиги и сложение (без команд работы с памятью, так как их поддержка будет добавлена позже).

## 5 лабораторная:
Задание: разработать блок загрузки-сохранения и перевести процессор на принстонскую архитектуру.

![image](https://user-images.githubusercontent.com/116370315/212535495-8ef5220a-4388-4e17-95a4-dc49a94152e3.png)

Ход работы: разработал модуль [RAM.sv](RAM.sv) с единой памяти команд и данных и модуль [LSU.sv](LSU.sv), подключил все это и перевел процессор на принстонскую архитектуру с побайтовой адресацией (ранее была пословная). Верифицировалась работа модулей с помощью набора ассемблерных команд работы с памятью (lw, sw, lh и т.д.) и анализа временных диаграмм.

## 6 лабораторная:
Задание: разработать и подключить к процессору подсистемы прерываний. 

![image](https://user-images.githubusercontent.com/116370315/212537011-fa40c95a-b738-42e8-a502-86c7c1abb454.png)

Ход работы: Был разработан модуль обработки прерываний [Interrupt_Controller.sv](Interrupt_Controller.sv) с циклическим опросом и модуль с регистрами специального назначения CSR.sv, так же был добработан модуль [main_decoder.sv](main_decoder.sv) - была добавлена поддержка команд для работы прерываний.
Тестировалась работа с помощью программы на языке ассемблера, где запускался бесконечный цикл, и в определенный момент в времени (заданные мной в тестбенче) формировался сигнал прерывания.

![image](https://user-images.githubusercontent.com/116370315/212537122-2f6e67bc-5a0b-4caa-8492-2703ed95193c.png)

## 7 лабораторная:
Задание: разработать модуль дешифрации адреса, подключить устройства ввода-вывода к процессору.

Ход работы: был написан модуль [Adres_decoder.sv](Adres_decoder.sv), который перенаправлял сигналы процессора к памяти/светодиодам/регистрам клавиатуры в зависимости от адреса ячейки памяти. Так же был написан модуль контроллера клавиатуры с интерфейсом PS/2 (простой,  на уровне считывания кода нажатой клавиши) и модуль управления динамическими семисегментниками.
Проверка осуществлялась на практике - я загрузил проект в плис, подключил к ней клавиатуру и проверил работу (код нажатой клавиши должен выводиться на диоды и на семисегментники в шестнадцатиричном формате) отчет по результату - на фото.

## 8 лабораторная:
Задание: ознакомиться с процессом компиляции программы на языке высокого уровня в программу на языке ассемблера и проверить правильность ее выполнения на своем процессоре. 

Ход работы: с помощью кросскомпилятора программа на языке С была переведена в машинные коды, которые были загружены в модуль памяти [RAM.sv](RAM.sv), после чего на временных диаграммах я отследил правильность выполнения. Верифицировать и писать новые модули на SV не пришлось, так как эта работа нацелена на изучение процессов компиляции программ с языков высокого уровня.

# Итог:
В результате лабораторного практикума я изучил SystemVerilog (в рамках тех приемов и конструкций, которые используются мной в написанных модулях), написал на нем процессор с набором инструкций RV32I со структурой на фото, изучил язык ассемблера и процесс компиляции высокоуровневых программ на примере программы с сортировкой массива данных несколькими способами (которая в итоге успешно работает).

![image](https://user-images.githubusercontent.com/116370315/212536698-8f3e629c-2ba1-402f-b45e-82f126f46c7c.png)
