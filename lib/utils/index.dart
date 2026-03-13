//订阅者回调签名
typedef void EventCallback(arg);

class EventBus {
  //私有构造函数
  EventBus._internal();

  //保存单例
  static EventBus _singleton = new EventBus._internal();

  //工厂构造函数
  factory EventBus() => _singleton;

  //保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列
  var _emap = new Map<Object, List<EventCallback>>();

  //添加订阅者
  void on(eventName, EventCallback f) {
    if (eventName == null) return;
    _emap[eventName] ??= <EventCallback>[];
    _emap[eventName]!.add(f);
  }

  //移除订阅者
  void off(eventName, [EventCallback? f]) {
    var list = _emap[eventName];
    if (eventName == null || list == null) return;
    if (f == null) {
      _emap.remove(eventName);
      return;
    }
    while (list.remove(f)) {}
    if (list.isEmpty) {
      _emap.remove(eventName);
    }
  }

  //触发事件，事件触发后该事件所有订阅者会被调用
  void emit(eventName, [arg]) {
    var list = _emap[eventName];
    if (list == null) return;
    final callbacks = List<EventCallback>.from(list);
    int len = callbacks.length - 1;
    //反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (var i = len; i > -1; --i) {
      final callback = callbacks[i];
      try {
        callback(arg);
      } catch (e) {
        // 自动清理失效监听，避免已销毁页面继续触发 setState
        if (e.toString().contains('setState() called after dispose()')) {
          off(eventName, callback);
          continue;
        }
        rethrow;
      }
    }
  }
}

//定义一个top-level（全局）变量，页面引入该文件后可以直接使用bus
var cgBus = new EventBus();
