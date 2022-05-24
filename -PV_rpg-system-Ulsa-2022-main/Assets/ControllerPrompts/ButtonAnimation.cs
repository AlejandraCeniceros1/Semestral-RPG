using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ButtonAnimation : MonoBehaviour
{
    Sprite originalSprite;
    public Sprite altSprite;
    
    void Start(){
        originalSprite = GetComponent<Image>().sprite;
        StartCoroutine(SwitchSprite());
    }

    IEnumerator SwitchSprite(){
        while(enabled)
        {
             yield return new WaitForSeconds(0.4f);
            GetComponent<Image>().sprite = altSprite;
            yield return new WaitForSeconds(0.4f);
            GetComponent<Image>().sprite = originalSprite;
        }
    }
}
