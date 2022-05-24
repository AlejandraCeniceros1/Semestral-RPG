using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MaggieMana : MonoBehaviour
{
    public Slider manaActual;

    [SerializeField]
    protected float _manaMaggie; 

    void Start()
    {
        manaActual.GetComponent<Slider>().value = _manaMaggie;


    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.X))
		{
		_manaMaggie -= 8.0f;
        }

    manaActual.GetComponent<Slider>().value = _manaMaggie;


        
    }
}
