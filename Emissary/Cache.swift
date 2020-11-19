//
//  Cache.swift
//  Emissary
//
//  Created by Jordan Kay on 4/8/16.
//  Copyright © 2016 Cultivr. All rights reserved.
//

public class Cache<K: Hashable, V> {
    private let capacity: Int
    private let queue: LinkedList<K, V>
    
    private var length = 0
    private var hashtable: [K: Node<K, V>]
    
    public init(capacity: Int) {
        self.capacity = capacity
        
        queue = LinkedList()
        hashtable = [K : Node<K, V>](minimumCapacity: capacity)
    }
    
    public subscript(key: K) -> V? {
        get {
            guard let node = hashtable[key] else { return nil }
            queue.remove(node)
            queue.addToHead(node)
            return node.value
        }
        
        set(value) {
            if let node = hashtable[key] {
                node.value = value
                
                queue.remove(node)
                queue.addToHead(node)
            } else {
                let node = Node(key: key, value: value)
                
                if length < capacity {
                    queue.addToHead(node)
                    hashtable[key] = node
                    length += 1
                } else {
                    hashtable.removeValue(forKey: queue.tail!.key)
                    queue.tail = queue.tail?.previous
                    
                    if let node = queue.tail {
                        node.next = nil
                    }
                    
                    queue.addToHead(node)
                    hashtable[key] = node
                }
            }
        }
    }
}

private class Node<K, V> {
    var next: Node?
    var previous: Node?
    var key: K
    var value: V?
    
    init(key: K, value: V?) {
        self.key = key
        self.value = value
    }
}

private class LinkedList<K, V> {
    var head: Node<K, V>?
    var tail: Node<K, V>?
    
    func addToHead(_ node: Node<K, V>) {
        if head == nil  {
            head = node
            tail = node
        } else {
            let temp = head
            
            head?.previous = node
            head = node
            head?.next = temp
        }
    }
    
    func remove(_ node: Node<K, V>) {
        if node === head {
            if head?.next != nil {
                head = head?.next
                head?.previous = nil
            } else {
                head = nil
                tail = nil
            }
        } else if node.next != nil {
            node.previous?.next = node.next
            node.next?.previous = node.previous
        } else {
            node.previous?.next = nil
            tail = node.previous
        }
    }
}
