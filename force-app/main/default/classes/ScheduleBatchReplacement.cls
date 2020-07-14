global class ScheduleBatchReplacement implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchProcessReplacementOrder b = new BatchProcessReplacementOrder();
		database.executebatch(b,100);
	}
}