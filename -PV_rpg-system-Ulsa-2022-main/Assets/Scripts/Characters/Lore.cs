using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[Serializable]
public class Lore 
{
    [SerializeField]
    string name;
    [SerializeField]
    Sprite spriteFrame;
    [SerializeField]
    int age;
    [SerializeField, TextArea(3, 5)]
    string history;
}
