public interface IDamagable
{
    int GetHealth();
    bool ImDead();
    void ReciveDamage(int damage);
    void AddHealt(int health);
}