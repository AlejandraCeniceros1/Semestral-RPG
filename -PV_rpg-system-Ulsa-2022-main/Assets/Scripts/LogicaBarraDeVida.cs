using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LogicaBarraDeVida : MonoBehaviour
{
    public Image barradeVida;

    public float vidaActual;

    public float vidaMax;

    

    void Update()
    {
        barradeVida.fillAmount = vidaActual/ vidaMax;
    }
}