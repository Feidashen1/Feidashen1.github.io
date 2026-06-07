学习一下 GDB 的东西和技巧，对自己比较模糊的地方做一下记录

# 1.列出函数的名字
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

## 2.函数

# 2.1 进入不带调试信息的函数
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


## 2.2 退出正在调试的函数
当单步调试一个函数时，如果不想继续跟踪下去了，可以有两种方式退出。

第一种用“finish”命令，这样函数会继续执行完，并且打印返回值，然后等待输入接下来的命令。

    (gdb) finish
    Run till exit from #N  func ()

第二种用“return”命令，这样函数不会继续执行下面的语句，而是直接返回。也可以用“return expression”命令指定函数的返回值。

    (gdb) return 40

## 2.3 直接执行函数
使用gdb调试程序时，可以使用“call”或“print”命令直接调用函数执行。
    (gdb) call func()
    $1 = 2
    (gdb) print func()
    $2 = 3

## 2.4 打印函数堆栈帧信息
使用gdb调试程序时，可以使用“i frame”命令（i是info命令缩写）显示函数堆栈帧信息。

    (gdb) i frame
    (gdb) i registers

查看main函数汇编代码：

    (gdb) disassemble main

当一个函数最后一条指令是调用另外一个函数时，开启优化选项的编译器常常以最后被调用的函数返回值作为调用者的返回值，这称之为“尾调用（Tail call）”。

## 2.5 切换函数堆栈

用gdb调试程序时，当程序暂停后，可以用“up n”或“down n”命令向上或向下选择函数堆栈帧，其中n是层数

程序断住后，假如先执行“frame 2”命令，切换到fun3函数。接着执行“up 1”命令，也就是会往外层的堆栈帧移动一层。反之，当执行“down 2”命令后，又会向内层堆栈帧移动二层。如果不指定n，则n默认为1.

还有“up-silently n”和“down-silently n”这两个命令，与“up n”和“down n”命令区别在于，切换堆栈帧后，不会打印信息

# 3. 断点

## 3.1 在匿名空间设置断点
在gdb中，如果要对namespace Foo中的foo函数设置断点，可以使用如下命令：

    (gdb) b Foo::foo
如果要对匿名空间中的bar函数设置断点，可以使用如下命令：

    (gdb) b (anonymous namespace)::bar

## 3.2 
当调试汇编程序，或者没有调试信息的程序时，经常需要在程序地址上打断点，方法为 b *address。例如：
    (gdb) b *0x400522

## 3.3 保存已经设置的断点
在gdb中，可以使用如下命令将设置的断点保存下来：

    (gdb) save breakpoints file-name-to-save

下次调试时，可以使用如下命令批量设置保存的断点：

    (gdb) source file-name-to-save

## 3.4 设置临时断点
在使用gdb时，如果想让断点只生效一次，可以使用“tbreak”命令（缩写为：tb）

    (gdb) tb a.c:15

## 3.5 设置条件断点
gdb可以设置条件断点，也就是只有在条件满足时，断点才会被触发，命令是“break … if cond”

    (gdb) b 10 if i==101
    Breakpoint 2 at 0x4004e3: file a.c, line 10.

设定断点只在i的值为101时触发

## 3.6 忽略断点
在设置断点以后，可以忽略断点，命令是“ignore bnum count”：意思是接下来count次编号为bnum的断点触发都不会让程序中断，只有第count + 1次断点触发才会让程序中断

    (gdb) ignore 1 5

可以看到设定忽略断点前5次触发

# 4.观察点

## 4.1 设置观察点
gdb可以使用“watch”命令设置观察点，也就是当一个变量值发生变化时，程序会停下来。

    (gdb) watch a
    Hardware watchpoint 2: a

使用“watch a”命令以后，当a的值变化：由0变成1，由1变成2，程序都会停下来。 此外也可以使用“watch *(data type*)address”这样的命令

先得到a的地址：0x6009c8，接着用“watch *(int*)0x6009c8”设置观察点，可以看到同“watch a”命令效果一样。 观察点可以通过软件或硬件的方式实现，取决于具体的系统。但是软件实现的观察点会导致程序运行很慢

## 4.2 设置观察点只针对特定线程生效
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

# 5.Catchpoint



# 参考文献
1. [100-gdb-tips](https://github.com/hellogcc/100-gdb-tips/blob/master/src/index.md)
