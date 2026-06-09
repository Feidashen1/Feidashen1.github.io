---
title: "GDB 命令及技巧"
date: 2026-06-07T22:00:00+08:00
draft: false
tags: ["GDB", "系统"]
categories: ["随笔"]
summary: "学习一下 GDB 的东西和技巧，对自己比较模糊的地方做一下记录。"
---

 
## 1. 列出函数的名字
gdb调试时，使用“`info functions`”命令可以列出可执行文件的所有函数名称。

    Thread 1 "wechat" received signal SIGINT, Interrupt.
    0x00007ffff251b4fd in __GI___poll (fds=0x55555e4b0cb0, nfds=3, timeout=-1)
        at ../sysdeps/unix/sysv/linux/poll.c:29
    warning: 29	../sysdeps/unix/sysv/linux/poll.c: 没有那个文件或目录
    (gdb) info functions
    All defined functions:

    File ../argp/argp-fmtstream.h:
    266:	size_t __argp_fmtstream_point(argp_fmtstream_t);
    220:	int __argp_fmtstream_putc(argp_fmtstream_t, int);
    207:	int __argp_fmtstream_puts(argp_fmtstream_t, const char *);
    230:	size_t __argp_fmtstream_set_lmargin(argp_fmtstream_t, size_t);
    242:	size_t __argp_fmtstream_set_rmargin(argp_fmtstream_t, size_t);
    254:	size_t __argp_fmtstream_set_wmargin(argp_fmtstream_t, size_t);
    194:	size_t __argp_fmtstream_write(argp_fmtstream_t, const char *, size_t);


可以看到会列出函数原型以及不带调试信息的函数。

另外这个命令也支持正则表达式：“`info functions regex`”，这样只会列出符合正则表达式的函数名称，例如：

	(gdb) info functions wech*

## 2. 函数

### 2.1 进入不带调试信息的函数
默认情况下，gdb 不会进入不带调试信息的函数。
可以执行“set step-mode on”命令，这样 gdb 就不会跳过没有调试信息的函数

    (gdb) set step-mode on
    (gdb) n
                 printf("%d,%d,%d,%d\n", st.a, st.b, st.c, st.d);
    (gdb) s
    0x00007ffff7a993b0 in printf () from /lib64/libc.so.6
    (gdb) s
    0x00007ffff7a993b7 in printf () from /lib64/libc.so.6

接下来可以使用调试汇编程序的办法去调试函数


### 2.2 退出正在调试的函数
当单步调试一个函数时，如果不想继续跟踪下去了，可以有两种方式退出。

第一种用“finish”命令，这样函数会继续执行完，并且打印返回值，然后等待输入接下来的命令。

    (gdb) finish
    Run till exit from #N  func ()

第二种用“return”命令，这样函数不会继续执行下面的语句，而是直接返回。也可以用“return expression”命令指定函数的返回值。

    (gdb) return 40

### 2.3 直接执行函数
使用gdb调试程序时，可以使用“call”或“print”命令直接调用函数执行。
    (gdb) call func()
    $1 = 2
    (gdb) print func()
    $2 = 3

### 2.4 打印函数堆栈帧信息
使用gdb调试程序时，可以使用“i frame”命令（i是info命令缩写）显示函数堆栈帧信息。

    (gdb) i frame
    (gdb) i registers

查看main函数汇编代码：

    (gdb) disassemble main

当一个函数最后一条指令是调用另外一个函数时，开启优化选项的编译器常常以最后被调用的函数返回值作为调用者的返回值，这称之为“尾调用（Tail call）”。

### 2.5 切换函数堆栈

用gdb调试程序时，当程序暂停后，可以用“up n”或“down n”命令向上或向下选择函数堆栈帧，其中n是层数

程序断住后，假如先执行“frame 2”命令，切换到fun3函数。接着执行“up 1”命令，也就是会往外层的堆栈帧移动一层。反之，当执行“down 2”命令后，又会向内层堆栈帧移动二层。如果不指定n，则n默认为1.

还有“up-silently n”和“down-silently n”这两个命令，与“up n”和“down n”命令区别在于，切换堆栈帧后，不会打印信息

#  
## 3. 断点

### 3.1 在匿名空间设置断点
在gdb中，如果要对namespace Foo中的foo函数设置断点，可以使用如下命令：

    (gdb) b Foo::foo
如果要对匿名空间中的bar函数设置断点，可以使用如下命令：

    (gdb) b (anonymous namespace)::bar

### 3.2 通过地址设置断点
当调试汇编程序，或者没有调试信息的程序时，经常需要在程序地址上打断点，方法为 b *address。例如：
    (gdb) b *0x400522

### 3.3 保存已经设置的断点
在gdb中，可以使用如下命令将设置的断点保存下来：

    (gdb) save breakpoints file-name-to-save

下次调试时，可以使用如下命令批量设置保存的断点：

    (gdb) source file-name-to-save

### 3.4 设置临时断点
在使用gdb时，如果想让断点只生效一次，可以使用“tbreak”命令（缩写为：tb）

    (gdb) tb a.c:15

### 3.5 设置条件断点
gdb可以设置条件断点，也就是只有在条件满足时，断点才会被触发，命令是“break … if cond”

    (gdb) b 10 if i==101
    Breakpoint 2 at 0x4004e3: file a.c, line 10.

设定断点只在i的值为101时触发

### 3.6 忽略断点
在设置断点以后，可以忽略断点，命令是“ignore bnum count”：意思是接下来count次编号为bnum的断点触发都不会让程序中断，只有第count + 1次断点触发才会让程序中断

    (gdb) ignore 1 5

可以看到设定忽略断点前5次触发

## 4. 观察点

### 4.1 设置观察点
gdb可以使用“watch”命令设置观察点，也就是当一个变量值发生变化时，程序会停下来。

    (gdb) watch a
    Hardware watchpoint 2: a

使用“watch a”命令以后，当a的值变化：由0变成1，由1变成2，程序都会停下来。 此外也可以使用“watch *(data type*)address”这样的命令

先得到a的地址：0x6009c8，接着用“watch *(int*)0x6009c8”设置观察点，可以看到同“watch a”命令效果一样。 观察点可以通过软件或硬件的方式实现，取决于具体的系统。但是软件实现的观察点会导致程序运行很慢

### 4.2 设置观察点只针对特定线程生效
gdb可以使用“watch expr thread threadnum”命令设置观察点只针对特定线程生效，也就是只有编号为threadnum的线程改变了变量的值，程序才会停下来，其它编号线程改变变量的值不会让程序停住。

需要注意的是这种针对特定线程设置观察点方式只对硬件观察点才生效

 - 硬件观察点与软件观察点（如在 GDB 调试 中）的主要区别在于其实现底层机制、运行速度以及支持的容量限制。观察点用于监控变量或内存地址，当其值被读取或写入时触发中断。


核心区别如下：

| 特性 | 硬件观察点 (Hardware Watchpoint) | 软件观察点 (Software Watchpoint) |
| :--- | :--- | :--- |
| **工作原理** | 利用 CPU 内部专门的调试寄存器监控内存。当 CPU 访问该地址时直接触发硬件中断。 | 调试器在每执行一条指令后，强行暂停程序，并在后台计算表达式的值。如果值改变，则触发中断。 |
| **运行速度** | **极快**。程序几乎全速运行，直到访问被监控的内存。 | **极慢**。程序运行速度会大幅下降，因为每执行一步都需要发生多次上下文切换和检查。 |
| **数量限制** | **非常有限**。通常受限于 CPU 的硬件调试寄存器数量（如 x86 架构通常只有 2 到 4 个）。 | **几乎无限制**。仅受系统可用内存大小的约束。 |
| **监控范围** | 受限于单次寄存器可监控的字节数（如每次 1、2、4 或 8 字节）。监控大型结构体或数组时较复杂。 | 更加灵活，可以监控任意大小的内存区域或复杂的表达式。 |



### 硬件观察点核心工作原理
硬件观察点的运行完全依靠底层芯片的硬件支持，其执行逻辑可以分为三个步骤：
 - 注册阶段：用户在调试器（如 GDB）中对某个变量设置观察点，调试器会将该变量的绝对内存地址写入 CPU 内部专用的调试寄存器（Debug Registers）。
 - 执行阶段：程序开始全速运行。由于这是硬件级别的监控，流水线在每一步执行内存访问指令时，CPU 的硬件逻辑会自动将当前操作的内存地址与调试寄存器中的地址进行硬件比对。这一过程对程序运行没有任何性能损耗。
 - 触发阶段：一旦某条指令访问的地址与调试寄存器相匹配，CPU 就会立即产生一个调试异常（Debug Exception）或硬件中断，挂起当前线程，并通知调试器。调试器此时会捕获该事件，让程序停在引发改变的代码行上。


 支持的监控类型硬件观察点非常强大，因为硬件寄存器允许细粒度地指定引发中断的“触发源”。通过配置控制寄存器，通常支持以下三种类型：
 - 写观察点（Write Watchpoint）：只有当内存被写入/修改时才触发（最常用，GDB 中对应 watch 命令）。
 - 读观察点（Read Watchpoint）：只有当内存被读取时才触发（GDB 中对应 rwatch 命令）。
 - 读写观察点（Access Watchpoint）：无论是被读取还是写入，只要发生访问就触发（GDB 中对应 awatch 命令）。

#  
## 5. Catchpoint

使用gdb调试程序时，可以用“tcatch”命令设置catchpoint只触发一次，

    (gdb) tcatch fork
    Catchpoint 1 (fork)
    (gdb) r

当程序只在第一次调用fork时暂停

使用gdb调试程序时，可以用“catch fork”命令为fork调用设置catchpoint

    (gdb) catch fork
    Catchpoint 1 (fork)
    (gdb) r

可以看到当fork调用发生后，gdb会暂停程序的运行,目前只有HP-UX和GNU/Linux支持这个功能

### 5.1 为系统调用设置catchpoint
使用gdb调试程序时，可以使用catch syscall [name | number]为关注的系统调用设置catchpoint

    (gdb) catch syscall mmap
    Catchpoint 1 (syscall 'mmap' [9])
    (gdb) r

当mmap调用发生后，gdb会暂停程序的运行。也可以使用系统调用的编号设置 catchpoint:

    (gdb) catch syscall 9
    Catchpoint 1 (syscall 'mmap' [9])
    (gdb) r

可以看到和使用catch syscall mmap效果是一样的。系统调用和编号的映射参考具体的xml文件，以我的系统为例，就是在/usr/local/share/gdb/syscalls文件夹下的amd64-linux.xml

如果不指定具体的系统调用，则会为所有的系统调用设置catchpoint

有些程序不想被gdb调试，它们就会在程序中调用“ptrace”函数，一旦返回失败，就证明程序正在被gdb等类似的程序追踪，所以就直接退出。

- ptrace 在 Linux 系统中的一个核心限制：一个进程在同一时间只能被一个追踪者（Tracer）挂载（Attach）
 - GDB 的工作原理：当你在 GDB 中启动一个程序，或者使用 gdb -p <pid> 挂载一个正在运行的程序时，GDB 底层会调用 ptrace(PTRACE_ATTACH, ...) 或 PTRACE_TRACEME。此时，GDB 已经成为了该程序的唯一追踪者。
 - 程序的反击（主动调用）：程序在启动时，自己主动调用一次 ptrace(PTRACE_TRACEME, 0, 0, 0)。这个调用的意思是：“我允许我的父进程来追踪我”。
 - 结果判定：
    - 正常运行（没有被调试）：程序正常启动，之前没有任何人追踪它。这次调用会成功返回 0。程序知道自己安全，继续执行正常业务逻辑。
    - 正在被调试（如 GDB 中）：因为 GDB 已经先一步挂载了该程序，此时程序自己再调用 ptrace，系统就会检测到“该进程已经有一个追踪者了”。于是，这次调用会失败返回 -1，并将错误码（errno）设置为 EPERM（权限拒绝）。
- 触发退出：程序检测到返回值是 -1，判定自己正处于被窥探、被分析的环境中，于是立即调用 exit() 闪退，从而保护自己的核心代码、密钥或业务逻辑不被逆向分析。

破解这类程序的办法就是为ptrace调用设置catchpoint，通过修改ptrace的返回值，达到目的。

通过修改rax寄存器的值，达到修改返回值的目的，从而让gdb可以继续调试程序

### 5.2 ptrace 函数
`ptrace` 是 Linux 系统中极其核心的一个系统调用，它提供了一种让父进程得以监视和控制子进程的能力。它是 **GDB、strace 等绝大多数调试工具和系统安全工具的底层基石**。

它的核心功能和使用场景如下：

### 核心功能
* **流程控制**：允许父进程暂停目标进程的运行，实现单步执行、设置断点等操作。
* **数据修改**：可以读取和修改目标进程的**内存**以及 **CPU 寄存器**。
* **系统调用拦截**：能够拦截目标进程每一次系统调用（syscall）的进入与退出。

### 常见应用场景
* **进程调试**：GDB 调试器利用 `ptrace` 挂载到目标程序上，获取栈信息和变量。
* **系统监控**：`strace` 工具通过它拦截并打印出进程的所有系统调用。
* **代码注入与沙箱**：反病毒软件、安全分析沙箱或动态链接库（so）注入工具利用其修改内存和控制执行流程。

### 函数原型
```c
#include <sys/ptrace.h>

long ptrace(enum __ptrace_request request, pid_t pid, void *addr, void *data);
```
* **`request`**：决定了要执行的具体操作（如 `PTRACE_TRACEME`, `PTRACE_PEEKTEXT`, `PTRACE_POKETEXT` 等）。
* **`pid`**：被追踪目标进程的进程 ID。
* **`addr`**：目标进程中的操作内存地址。
* **`data`**：用于读取或写入的数据缓存区。


## 6. 打印

### 6.1 打印 ASCII 码
用gdb调试程序时，可以使用“x/s”命令打印ASCII字符串：

    (gdb) x/s str1
    0x804779f:      "abcd"

打印宽字符字符串时，要根据宽字符的长度决定如何打印：
    (gdb) x/ws str2
    0x8047788:      U"abcd"

当前平台宽字符的长度为4个字节，则用“x/ws”命令。如果是2个字节，则用“x/hs”命令。


### 6.2 打印 STL 容器中的内容
在gdb中，如果要打印C++ STL容器的内容，缺省的显示结果可读性很差：

```bash
(gdb) p vec
$1 = {<std::_Vector_base<int, std::allocator<int> >> = {
    _M_impl = {<std::allocator<int>> = {<__gnu_cxx::new_allocator<int>> = {<No data fields>}, <No data fields>}, _M_start = 0x404010, _M_finish = 0x404038, 
        _M_end_of_storage = 0x404038}}, <No data fields>}
```

目前一些发行版本已经具有可以解析的脚本

如果没有则可以参考：https://github.com/hellogcc/100-gdb-tips/blob/master/src/print-STL-container.md

### 6.3 打印大数组中的内容
在gdb中，如果要打印大数组的内容，缺省最多会显示200个元素,可以使用如下命令，设置这个最大限制数：

    (gdb) set print elements number-of-elements

也可以使用如下命令，设置为没有限制：

    (gdb) set print elements 0
    (gdb) set print elements unlimited

在gdb中，如果要打印数组中任意连续元素的值，可以使用“p array[index]@num”命令（p是print命令的缩写）。其中index是数组索引（从0开始计数），num是连续多少个元素。

    (gdb) p array[60]@10

打印了array数组第60~69个元素的值

如果要打印从数组开头连续元素的值，也可使用这个命令：“p *array@num”:

    (gdb) p *array@10

在gdb中，当打印一个数组时，缺省是不打印索引下标的,如果要打印索引下标，则可以通过如下命令进行设置：

    (gdb) set print array-indexes on

利用call函数控制数组的输出格式

    (gdb) call print(matrix, 10, 10) // 通过函数调用格式化输出数组

### 6.4 打印进程内存信息
用gdb调试程序时，如果想查看进程的内存映射信息，可以使用“i proc mappings”命令（i是info命令缩写）:

此外，也可以用"i files"（还有一个同样作用的命令：“i target”）命令，它可以更详细地输出进程的内存信息，包括引用的动态链接库等等

在gdb中，如果直接打印静态变量:

(gdb) p var

可以显式地指定文件名（上下文）：

    (gdb) p 'static-1.c'::var
    $1 = 1

### 6.5 打印变量的类型和所在文件
在gdb中，可以使用如下命令查看变量的类型：

    (gdb) whatis he
    type = struct child

如果想查看详细的类型信息：

    (gdb) ptype he
    type = struct child {
        char name[10];
        enum {boy, girl} gender;
    }

如果想查看定义该变量的文件：

    (gdb) i variables he
    All variables matching regular expression "he":

    File variable.c:
    struct child he;

gdb会显示所有包含（匹配）该表达式的变量。如果只想查看完全匹配给定名字的变量：

    (gdb) i variables ^he$
    All variables matching regular expression "^he$":

    File variable.c:
    struct child he;

### 6.6 打印内存的值
gdb中使用“x”命令来打印内存的值，格式为“x/nfu addr”。含义为以f格式打印从addr开始的n个长度单元为u的内存值。参数具体含义如下：
- a）n：输出单元的个数。
- b）f：是输出格式。比如x是以16进制形式输出，o是以8进制形式输出,等等。
- c）u：标明一个单元的长度。b是一个byte，h是两个byte（halfword），w是四个byte（word），g是八个byte（giant word）。


### 6.7 打印源代码行

在gdb中可以使用list（简写为l）命令来显示源代码以及行号。list命令可以指定行号，函数：

    (gdb) l 24
    (gdb) l main

还可以指定向前或向后打印：

    (gdb) l -
    (gdb) l +

还可以指定范围：

    (gdb) l 1,10

默认情况下，gdb以一种“紧凑”的方式打印结构体。结构体的显示很混乱，尤其是结构体里还嵌套着其它结构体时。

可以执行“set print pretty on”命令，这样每行只会显示结构体的一名成员，而且还会根据成员的定义层次进行缩进：

    (gdb) set print pretty on
    (gdb) p st
    $2 = {
        a = 1,
        b = 2,
        c = 3,
        d = 4,
        mutex = {
        __data = {
            __lock = 0,
            __count = 0,
            __owner = 0,
            __nusers = 0,
            __kind = 0,
            __spins = 0,
            __list = {
                __prev = 0x0,
                __next = 0x0
            }
        },
        __size = '\000' <repeats 39 times>,
        __align = 0
        }
    }

### 6.8 按照派生类型打印对象

如果要缺省按照派生类型进行打印，则可以通过如下命令进行设置：

    (gdb) set print object on
    (gdb) p p
    $2 = (Circle &) @0x7fffffffde90: {<Shape> = {_vptr.Shape = 0x400a80 <vtable for Circle+16>}, radius = 1}

### 6.9 使用“$_”和“$__”变量

"x"命令会把最后检查的内存地址值存在“$_”这个“convenience variable”中，并且会把这个地址中的内容放在“$__”这个“convenience variable”，


#  
## 7. 多线程与多进程

### 7.1 调试已经运行的进程

调试已经运行的进程有两种方法：一种是gdb启动时，指定进程的ID：gdb program processID（也可以用-p或者--pid指定进程ID，例如：gdb program -p=10210）。

另一种是先启动gdb，然后用“attach”命令“附着”在进程上：

    gdb -q a
    Reading symbols from /data/nan/a...done.
    (gdb) attach 10210

如果不想继续调试了，可以用“detach”命令“脱离”进程：

    (gdb) detach


如果要调试子进程，要使用如下命令：“set follow-fork-mode child” {这个命令目前Linux支持，其它很多操作系统都不支持}:

    (gdb) set follow-fork-mode child
    (gdb) start

### 7.2 同时调试父进程与子进程

在调试多进程程序时，gdb默认只会追踪父进程的运行，而子进程会独立运行，gdb不会控制。

如果要同时调试父进程和子进程，可以使用“set detach-on-fork off”（默认detach-on-fork是on）命令，这样gdb就能同时调试父子进程，并且在调试一个进程时，另外一个进程处于挂起状态。

在使用“set detach-on-fork off”命令后，用“i inferiors”（i是info命令缩写）查看进程状态，可以看到父子进程都在被gdb调试的状态，前面显示“*”是正在调试的进程。当父进程退出后，用“inferior infno”切换到子进程去调试。

此外，如果想让父子进程都同时运行，可以使用“set schedule-multiple on”（默认schedule-multiple是off）命令

https://github.com/hellogcc/100-gdb-tips/blob/master/src/set-detach-on-fork.md


### 7.3 查看线程信息

用gdb调试多线程程序，可以用“i threads”命令（i是info命令缩写）查看所有线程的信息

      (gdb) i threads
            Id   Target Id         Frame
            3    Thread 0x7ffff6e2b700 (LWP 31773) 0x00007ffff7915911 in clone () from /lib64/libc.so.6
            2    Thread 0x7ffff782c700 (LWP 31744) 0x00007ffff78d9bcd in nanosleep () from /lib64/libc.so.6
            * 1    Thread 0x7ffff7fe9700 (LWP 31738) main () at a.c:18

第一项（Id）：是gdb标示每个线程的唯一ID：1，2等等。

第二项（Target Id）：是具体系统平台用来标示每个线程的ID，不同平台信息可能会不同。 像当前Linux平台显示的就是： Thread 0x7ffff6e2b700 (LWP 31773)。

第三项（Frame）：显示的是线程执行到哪个函数。

前面带“*”表示的是“current thread”，可以理解为gdb调试多线程程序时，选择的一个“默认线程”。

也可以用“i threads [Id...]”指定打印某些线程的信息

使用"thread thread-id"实现不同线程之间的切换，查看指定线程的堆栈信息

使用"thread apply [thread-id-list] [all] args"可以在多个线程上执行命令，例如：thread apply all bt可以查看所有线程的堆栈信息。

    (gdb) thread apply all bt

thread apply [thread-id-list] [all] args 也可以对指定的线程ID列表进行执行：

    (gdb) thread apply 1-2 bt  #打印两个线程 1,2


[一个gdb会话中同时调试多个程序](https://github.com/hellogcc/100-gdb-tips/blob/master/src/add-copy-inferiors.md)

### 7.4 “$_thread”变量 与 “$_exitcode”变量

gdb从7.2版本引入了$_thread这个“convenience variable”，用来保存当前正在调试的线程号。这个变量在写断点命令或是命令脚本时会很有用。

当被调试的程序正常退出时，gdb会使用$_exitcode这个“convenience variable”记录程序退出时的“exit code”
* 存储程序通过 `main` 函数返回或调用 `exit()` 正常退出的返回值。
* **注意**：若程序因段错误（`SIGSEGV`）等信号异常崩溃，该变量**不会**被赋值。


| 变量名称 | 存储内容类型 | 对应 GDB 命令 | 核心应用场景 |
| :--- | :--- | :--- | :--- |
| **`$_thread`** | 当前线程的 **GDB 内部编号** | `info threads` | 复杂的多线程条件断点设置 |
| **`$_exitcode`** | 程序正常结束后的 **退出状态码** | `print $_exitcode` | 自动化脚本判断程序运行结果 |



#  
## 8. coredump
在用gdb调试程序时，我们有时想让被调试的进程产生core dump文件，记录现在进程的状态，以供以后分析。可以用“generate-core-file”命令来产生core dump文件

有时我们想在gdb启动后，动态加载可执行程序和core dump文件，这时可以用“file”和“core”（core-file命令缩写）命令。“file”命令用来读取可执行文件的符号表信息，而“core”命令则是指定core dump文件的位置:

    bash-3.2# gdb -q
    (gdb) file /data/nan/a
    Reading symbols from /data/nan/a...done.
    (gdb) core /var/core/core.a.22268.1402638140

#  
## 9. 显示共享链接库信息
使用"info sharedlibrary regex"命令可以显示程序加载的共享链接库信息，其中regex可以是正则表达式，意为显示名字符合regex的共享链接库。如果没有regex，则列出所有的库。

#  
## 10. 图像化界面
启动 gdb 时指定 `-tui` 参数（例如：gdb -tui program），或者运行 gdb 过程中使用 `Ctrl+X, A`（先按 Ctrl+X 再按 A）组合键，都可以进入图形化调试界面。退出图形化调试界面也是使用相同组合键。

使用gdb图形化调试界面时，可以使用“layout regs”命令显示寄存器窗口

* 如果想查看浮点寄存器，可以使用“tui reg float”命令
* “tui reg system”命令显示系统寄存器
* 想切换回显示通用寄存器内容，可以使用“tui reg general”命令

使用gdb图形化调试界面时，可以使用“winheight  <win_name> [+ | -]count”命令调整窗口大小（winheight缩写为win。win_name可以是src、cmd、asm和regs）。




#  
## 参考文献
1. [100-gdb-tips](https://github.com/hellogcc/100-gdb-tips/blob/master/src/index.md)


以上内容主要整理自参考文献，便于查阅；文中示例以 GNU/Linux 为主。

