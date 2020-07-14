global class ScheduleBatchDelayedContractActivation implements Schedulable {
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new BatchDelayedContractActivation());
	}
}