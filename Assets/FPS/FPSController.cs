using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPSController : MonoBehaviour
{
    Rigidbody rb;
    Animator anim;

    [Header("movimiento")]

     Vector2 movInput;
    public Transform body;

    public float aceleracion = 100;
    public float velMaxima;
    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        anim = GetComponentInChildren<Animator>();
    }
    private void Update()
    {
        movInput = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));

        anim.SetInteger("velocidad",Mathf.RoundToInt(Mathf.Abs(movInput.magnitude)));

    }

    private void FixedUpdate()
    {
        if(Mathf.Abs(rb.velocity.magnitude) <= velMaxima)
        {
            rb.AddForce((body.forward * movInput.y + body.right * movInput.x) * aceleracion * Time.deltaTime);
        }
        else
        {
            rb.velocity = (body.forward * movInput.y + body.right * movInput.x) *  velMaxima;
        }
    }

}
