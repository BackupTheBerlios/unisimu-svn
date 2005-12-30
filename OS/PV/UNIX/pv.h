#ifndef _PV_H_
#define _PV_H_

/* ���淵������Ϊ int �ĺ������Է��� 1 ��ʾ�����ɹ���
   ���� 0 ��ʾ����ʧ�� */

/* P ������key ���ź����ļ�ֵ */
int P(int key);

/* V ������key ���ź����ļ�ֵ */
int V(int key);

/* ���������ڴ棬key �Ǹ��ڴ��Ӧ�ļ�ֵ,
   len �Ǹ��ڴ�Ĵ�С�����ֽ�Ϊ��λ��*/
int create_shared_mem(int key, int len);

/* ��ָ���ļ�ֵ key �����ź�����������ֵΪ val */
int create_sema(int key, int val);

/* ��ȡ��ֵ key ��Ӧ�Ĺ����ڴ���׵�ַ,
   len ������ʵ�ʴ�С��ȫһ�� */
void* get_shared_mem(int key, int len);

/* ����ɶ� get_shard_mem ���صĹ���ָ��
   �Ĳ����Ժ��˻ظ�ָ��� OS */
void commit_shared_ptr(void* ptr);

#endif
