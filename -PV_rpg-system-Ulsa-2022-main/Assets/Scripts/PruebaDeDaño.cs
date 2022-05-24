using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class PruebaDeDaño : MonoBehaviour
{

    public LogicaBarraDeVida logicaBarraDeVidaMonstruo;

    public float daño = 2.0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(1))
        {
            logicaBarraDeVidaMonstruo.vidaActual -= daño;
            

        }
        
    }
}
