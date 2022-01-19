### sonyflake
>雪花算法 [go - Sonyflake](https://github.com/sony/sonyflake) 的仓颉实现

    39 bits for time in units of 10 msec
     8 bits for a sequence number
    16 bits for a machine id

### 使用
- 下载代码并创建cpm项目， sonyflake和需要使用的项目目录平级(否则自行修改依赖的path字段)
```shell
$ cd ~/CodeToCangjie
$ git clone https://gitee.com/HW-PLLab/sonyflake.git
$ mkdir sonyflake-demo
$ cd sonyflake-demo
$ cpm new test demo
```
- 在`sonyflake-demo/module.json`添加`requires`
```json
"requires": {
	"sonyflake": {
		"organization": "ystyle",
		"version":"1.0.0",
		"path": "../sonyflake"
	  }
}
```
- 导入包
```cj
from sonyflake import sonyflake.*
```

### sample
```go
from sonyflake import sonyflake.*

func main() {
    let st  = Setting(1)
    let sf = Sonyflake(st)
    let id = sf.NextID()
    println("id: ${id}")
}
```